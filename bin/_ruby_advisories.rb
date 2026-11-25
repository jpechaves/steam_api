# frozen_string_literal: true

require "date"
require "yaml"

# Checks Ruby versions against ruby-advisory-db's interpreter advisories
# (rubies/ruby/*.yml). bundler-audit only checks Gemfile.lock, not the Ruby
# that runs it.
module RubyAdvisories
  # Where `bundler-audit update` keeps its copy of ruby-advisory-db
  DEFAULT_DATABASE = File.join(Dir.home, ".local", "share", "ruby-advisory-db")

  Advisory = Struct.new(:id, :title, :url, :patched, :unaffected, keyword_init: true) do
    def affects?(version)
      (patched + unaffected).none? { |requirement| requirement.satisfied_by?(version) }
    end

    def to_s = "#{id}: #{title} (patched: #{patched.map(&:to_s).join(" | ")}) #{url}"
  end

  module_function

  # @param database [String] a ruby-advisory-db checkout
  # @return [Array<RubyAdvisories::Advisory>]
  def load(database)
    files = Dir[File.join(database, "rubies", "ruby", "*.yml")].sort
    raise ArgumentError, "No Ruby advisories in #{database}; run `bundle exec bundler-audit update`." if files.empty?

    files.map { |file| parse(YAML.safe_load_file(file, permitted_classes: [Date]), File.basename(file, ".yml")) }
  end

  # @param id [String] the file's name, e.g. "CVE-2025-24294" or "GHSA-3p8q-wmhx-vm2w"
  def parse(data, id)
    Advisory.new(
      id: id,
      title: data["title"],
      url: data["url"],
      patched: requirements(data["patched_versions"]),
      unaffected: requirements(data["unaffected_versions"])
    )
  end

  # "~> 3.3.14" or ">= 2.0, < 2.1"
  def requirements(list) = Array(list).map { |item| Gem::Requirement.new(*item.split(/,\s*/)) }

  # @param version [String] e.g. "3.3.4"
  # @param advisories [Array<RubyAdvisories::Advisory>]
  # @return [Array<RubyAdvisories::Advisory>] the advisories affecting that version
  def affecting(version, advisories)
    parsed = Gem::Version.new(version)
    advisories.select { |advisory| advisory.affects?(parsed) }
  end
end
