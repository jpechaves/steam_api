# frozen_string_literal: true

require_relative "lib/steam_api_client/version"

Gem::Specification.new do |spec|
  spec.name = "steam_api_client"
  spec.version = SteamApiClient::VERSION
  spec.authors = ["João Pedro"]
  spec.email = ["pedrochaveslimas3@gmail.com"]

  spec.summary = "A ruby client to fetch from the public Steam Web API"
  spec.homepage = "https://github.com/sosolidkk/steam_api"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0"

  spec.metadata["homepage_uri"] = spec.homepage
  # Require MFA for every `gem push` of this gem
  spec.metadata["rubygems_mfa_required"] = "true"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "bin"
  spec.executables = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # A mixin to add configuration functionality to your classes.
  # See: [https://rubygems.org/gems/dry-configurable]
  spec.add_dependency "dry-configurable", "~> 1.1.0"
  # Typed struct and value objects for Ruby.
  # See: [https://rubygems.org/gems/dry-struct]
  spec.add_dependency "dry-struct", "~> 1.6"
  # Typhoeus runs HTTP requests in parallel while
  # cleanly encapsulating handling logic.
  # See [https://rubygems.org/gems/typhoeus]
  spec.add_dependency "typhoeus", "~> 1.4"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
