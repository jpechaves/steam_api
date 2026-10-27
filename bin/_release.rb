# frozen_string_literal: true

# Publishes the gem to RubyGems and tags the release on GitHub.
#
# Every step is skipped when it's already done, so running it again for a
# released version does nothing, and a half-finished release (gem pushed but
# tag missing, or the other way round) can be completed by running it again.
class Release
  class Error < StandardError; end

  GEM_NAME = "steam_api_client"

  # @param shell [#run, #capture] runs commands; #capture returns their output
  # @param rubygems [#published?] tells if a version of a gem is on RubyGems
  # @param version [#call] returns the gem version (read after pulling main)
  # @param changelog [#call] returns the contents of CHANGELOG.md
  # @param confirm [#call] asks a yes/no question, returns true for yes
  # @param dry_run [Boolean] print the build/push/tag steps instead of running them
  # @param out [IO]
  def initialize(shell:, rubygems:, version:, changelog:, confirm:, dry_run: false, out: $stdout)
    @shell = shell
    @rubygems = rubygems
    @version = version
    @changelog = changelog
    @confirm = confirm
    @dry_run = dry_run
    @out = out
  end

  # @return [Symbol] :released, :tagged, :already_released or :aborted
  # @raise [Release::Error] when the release can't go ahead safely
  def call
    ensure_clean_tree!
    shell.run("git checkout main")
    shell.run("git pull --ff-only origin main")

    @tag = "v#{version.call}"
    published = rubygems.published?(GEM_NAME, tag.delete_prefix("v"))
    # main usually moves on after a release, so check this before comparing the tag with HEAD
    return already_released if published && remote_tag

    ensure_changelog_entry!
    ensure_nothing_unreleased!
    ensure_remote_tag_matches_head!
    return tag_published_version if published

    publish_gem
    tag_release unless remote_tag
    say(@dry_run ? "Dry run: #{tag} would be released." : "🚀 Released #{tag}.")
    :released
  end

  private

  attr_reader :shell, :rubygems, :version, :changelog, :confirm, :out, :tag

  def ensure_clean_tree!
    return if shell.capture("git status --porcelain --untracked-files=no").strip.empty?

    raise Error, "There are uncommitted changes. Commit or stash them before releasing."
  end

  def ensure_changelog_entry!
    return if changelog.call.include?("## [#{tag.delete_prefix("v")}]")

    raise Error, "CHANGELOG.md has no \"## [#{tag.delete_prefix("v")}]\" section. Add one before releasing."
  end

  # Entries under [Unreleased] are changes on main that aren't part of this
  # version, so publishing main would ship them under the wrong CHANGELOG section
  def ensure_nothing_unreleased!
    unreleased = changelog.call[/^## \[Unreleased\]\s*$(.*?)(?=^## \[|\z)/m, 1]
    return if unreleased.nil? || unreleased.strip.empty?

    raise Error, "CHANGELOG.md has entries under \"## [Unreleased]\": main has changes that aren't part of #{tag}. " \
      "Run bin/bump to release them as a new version."
  end

  def ensure_remote_tag_matches_head!
    return if remote_tag.nil? || remote_tag == head

    raise Error, "Tag #{tag} already points to #{remote_tag}, not to main (#{head}). Bump the version instead."
  end

  def already_released
    say "✅ #{tag} is already released (on RubyGems and tagged). Nothing to do."
    :already_released
  end

  def tag_published_version
    unless @dry_run || confirm.call("#{tag} is on RubyGems but not tagged. Tag main (#{head}) as #{tag}?")
      say "Stopped without tagging."
      return :aborted
    end

    tag_release
    :tagged
  end

  def publish_gem
    gem_file = "pkg/#{GEM_NAME}-#{tag.delete_prefix("v")}.gem"

    mutate("mkdir -p pkg")
    mutate("gem build #{GEM_NAME}.gemspec --output #{gem_file}")
    # Interactive: RubyGems asks for the MFA one-time password here
    mutate("gem push #{gem_file}")
  end

  def tag_release
    local_tag = shell.capture("git rev-parse -q --verify refs/tags/#{tag}^{commit}").strip
    raise Error, "Local tag #{tag} points to #{local_tag}, not to main (#{head})." unless local_tag.empty? || local_tag == head

    mutate("git tag -a #{tag} -m \"Release #{tag}\"") if local_tag.empty?
    mutate("git push origin #{tag}")
  end

  def mutate(command)
    @dry_run ? say("[dry run] #{command}") : shell.run(command)
  end

  def head
    @head ||= shell.capture("git rev-parse HEAD").strip
  end

  # Commit the tag points to on origin (peeled for annotated tags), or nil
  def remote_tag
    return @remote_tag if defined?(@remote_tag)

    refs = shell.capture("git ls-remote --tags origin refs/tags/#{tag} refs/tags/#{tag}^{}").lines.map(&:split).to_h(&:reverse)
    @remote_tag = refs["refs/tags/#{tag}^{}"] || refs["refs/tags/#{tag}"]
  end

  def say(message)
    out.puts(message)
  end
end
