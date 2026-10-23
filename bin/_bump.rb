# frozen_string_literal: true

# Prepares a release PR: bumps the gem version and moves the CHANGELOG's
# [Unreleased] entries under the new version. Nothing is committed or pushed.
module Bump
  class Error < StandardError; end

  GEM_NAME = "steam_api_client"
  LEVELS = %w[patch minor major].freeze
  UNRELEASED = "## [Unreleased]\n"

  module_function

  # Bumps the version files under root and prints the next steps.
  # Every edit is computed before writing, so a failure leaves the files untouched.
  # @return [String] the new version
  def call(level:, root:, date:, out: $stdout)
    paths = {
      version: File.join(root, "lib/#{GEM_NAME}/version.rb"),
      lockfile: File.join(root, "Gemfile.lock"),
      changelog: File.join(root, "CHANGELOG.md")
    }
    current = File.read(paths[:version])[/VERSION = "([^"]+)"/, 1] or raise Error, "No VERSION found in #{paths[:version]}"
    new_version = next_version(current, level)

    updates = {
      paths[:version] => version_file(File.read(paths[:version]), new_version),
      paths[:lockfile] => lockfile(File.read(paths[:lockfile]), current, new_version),
      paths[:changelog] => changelog(File.read(paths[:changelog]), from: current, to: new_version, date: date)
    }
    updates.each { |path, content| File.write(path, content) }

    out.puts <<~TEXT
      Bumped #{current} → #{new_version} (version.rb, Gemfile.lock, CHANGELOG.md).
      Next: commit on a release branch, open the "Release #{new_version}" PR, merge it, then run bin/release.
    TEXT
    new_version
  end

  # @param level [String] patch, minor or major
  def next_version(current, level)
    raise Error, "Level must be patch, minor or major (got #{level.inspect})" unless LEVELS.include?(level)

    major, minor, patch = Gem::Version.new(current).segments
    case level
    when "patch" then "#{major}.#{minor}.#{patch + 1}"
    when "minor" then "#{major}.#{minor + 1}.0"
    when "major" then "#{major + 1}.0.0"
    end
  end

  def version_file(source, version)
    source.sub(/VERSION = "[^"]+"/) { %(VERSION = "#{version}") }
  end

  def lockfile(source, from, to)
    entry = "    #{GEM_NAME} (#{from})"
    raise Error, "Gemfile.lock has no \"#{entry.strip}\" entry" unless source.include?(entry)

    source.sub(entry, "    #{GEM_NAME} (#{to})")
  end

  # Moves the [Unreleased] entries under "## [to] - date" and updates the compare links
  def changelog(source, from:, to:, date:)
    start = source.index(UNRELEASED) or raise Error, "CHANGELOG.md has no \"## [Unreleased]\" section"
    body_start = start + UNRELEASED.size
    body_end = source.index(/^## \[|^\[Unreleased\]:/, body_start) || source.size
    entries = source[body_start...body_end].strip
    raise Error, "There's nothing under [Unreleased] in CHANGELOG.md, so there's nothing to release" if entries.empty?

    bumped = "#{source[0...body_start]}\n## [#{to}] - #{date}\n\n#{entries}\n\n#{source[body_end..]}"
    compare_links(bumped, from, to)
  end

  def compare_links(source, from, to)
    link = %r{^\[Unreleased\]: (?<base>\S+)/compare/v#{Regexp.escape(from)}\.\.\.HEAD$}
    match = source.match(link) or raise Error, "CHANGELOG.md has no \"[Unreleased]: …/compare/v#{from}...HEAD\" link"

    source.sub(link, "[Unreleased]: #{match[:base]}/compare/v#{to}...HEAD\n[#{to}]: #{match[:base]}/compare/v#{from}...v#{to}")
  end
end
