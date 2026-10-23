# frozen_string_literal: true

# Decides whether a pull request needs a CHANGELOG entry: changes to the
# gem's code or gemspec are user-visible and must add an [Unreleased] line,
# unless the PR is labelled skip-changelog.
module ChangelogCheck
  SKIP_LABEL = "skip-changelog"
  CHANGELOG = "CHANGELOG.md"
  USER_VISIBLE = %r{\A(?:lib/|steam_api_client\.gemspec\z)}

  Result = Struct.new(:ok, :message) do
    alias_method :ok?, :ok
  end

  module_function

  # @param changed_files [Array<String>] paths changed by the PR
  # @param labels [Array<String>] the PR's label names
  # @return [ChangelogCheck::Result]
  def call(changed_files:, labels:)
    user_visible = changed_files.grep(USER_VISIBLE)

    if user_visible.empty?
      Result.new(true, "No user-visible files changed; no CHANGELOG entry needed.")
    elsif changed_files.include?(CHANGELOG)
      Result.new(true, "#{CHANGELOG} was updated.")
    elsif labels.include?(SKIP_LABEL)
      Result.new(true, "User-visible files changed, but the PR is labelled #{SKIP_LABEL}.")
    else
      Result.new(false, <<~TEXT)
        These user-visible files changed without a #{CHANGELOG} entry:
        #{user_visible.map { |file| "  - #{file}" }.join("\n")}

        Add a line under "## [Unreleased]" in #{CHANGELOG} (Added / Changed / Fixed / Security, with the issue number),
        or label the PR "#{SKIP_LABEL}" if the change isn't visible to users of the gem.
      TEXT
    end
  end
end
