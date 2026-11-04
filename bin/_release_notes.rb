# frozen_string_literal: true

# Builds a GitHub Release's notes from a version's CHANGELOG.md section, and
# finds the previous released tag, where GitHub's generated notes start from.
module ReleaseNotes
  class Error < StandardError; end

  HEADING = /^## \[(?<version>[^\]]+)\](?<rest>.*)$/
  # The compare links at the bottom of the CHANGELOG: "[1.0.0]: https://..."
  LINK_REFERENCE = /^\[[^\]]+\]: \S+\s*$/
  # Markdown links to files in the repository, e.g. [usage](docs/USAGE.md)
  RELATIVE_LINK = %r{\]\((?!https?://|#|mailto:)([^)\s]+)\)}

  Section = Struct.new(:version, :yanked, :body)
  Result = Struct.new(:notes, :previous_tag)

  module_function

  # @param changelog [String] the contents of CHANGELOG.md
  # @param tag [String] e.g. "v1.5.0"
  # @param repo [String] "owner/name", for links to files at the tag
  # @return [ReleaseNotes::Result]
  # @raise [ReleaseNotes::Error] when the version has no section, or was yanked
  def call(changelog:, tag:, repo:)
    sections = parse(changelog)
    index = sections.index { |section| section.version == tag.delete_prefix("v") }
    raise Error, "CHANGELOG.md has no \"## [#{tag.delete_prefix("v")}]\" section." unless index

    section = sections[index]
    raise Error, "#{tag} was yanked; it gets no release." if section.yanked

    previous = sections.drop(index + 1).find { |candidate| !candidate.yanked }
    Result.new(absolute_links(section.body, repo, tag), previous && "v#{previous.version}")
  end

  # The released versions, newest first ([Unreleased] left out)
  def parse(changelog)
    changelog.split(/(?=^## \[)/).filter_map do |chunk|
      heading, body = chunk.split("\n", 2)
      match = HEADING.match(heading)
      next if match.nil? || match[:version] == "Unreleased"

      Section.new(match[:version], match[:rest].include?("[YANKED]"), body.to_s.gsub(LINK_REFERENCE, "").strip)
    end
  end

  # Relative links resolve against the Release page, not the repository
  def absolute_links(body, repo, tag)
    body.gsub(RELATIVE_LINK) { "](https://github.com/#{repo}/blob/#{tag}/#{$1})" }
  end
end
