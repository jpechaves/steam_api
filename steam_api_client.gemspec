# frozen_string_literal: true

require_relative "lib/steam_api_client/version"

Gem::Specification.new do |spec|
  spec.name = "steam_api_client"
  spec.version = SteamApiClient::VERSION
  spec.authors = ["João Pedro"]
  spec.email = ["pedrochaveslimas3@gmail.com"]

  spec.summary = "A ruby client to fetch from the public Steam Web API"
  spec.description = <<~DESCRIPTION.tr("\n", " ").strip
    A Ruby client for the Steam Web API (player summaries, friends, owned and recent games,
    achievements, stats, levels, vanity URLs, app news, current players) and the Storefront API
    (app details). Responses come back as typed structs, and HTTP failures as specific error classes.
  DESCRIPTION
  spec.homepage = "https://github.com/jpechaves/steam_api"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.3"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata["bug_tracker_uri"] = "#{spec.homepage}/issues"
  spec.metadata["documentation_uri"] = "https://rubydoc.info/gems/steam_api_client"
  # Require MFA for every `gem push` of this gem
  spec.metadata["rubygems_mfa_required"] = "true"

  # Ship only the library code and its docs. Development files (bin/, specs,
  # Gemfile, tooling config) stay out of the packaged gem.
  spec.files = Dir.chdir(__dir__) do
    Dir["lib/**/*.rb", "LICENSE", "README.md", "CHANGELOG.md"]
  end
  spec.require_paths = ["lib"]

  # A mixin to add configuration functionality to your classes.
  # See: [https://rubygems.org/gems/dry-configurable]
  spec.add_dependency "dry-configurable", "~> 1.1"
  # Typed struct and value objects for Ruby.
  # See: [https://rubygems.org/gems/dry-struct]
  spec.add_dependency "dry-struct", "~> 1.6"
  # HTTP client with pluggable adapters (Net::HTTP by default) and middleware.
  # See [https://rubygems.org/gems/faraday]
  spec.add_dependency "faraday", "~> 2.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
