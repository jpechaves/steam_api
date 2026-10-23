# frozen_string_literal: true

require "bundler/setup"

require "simplecov"
SimpleCov.start do
  # Measure the gem only: specs and bin/ tooling would inflate the numbers
  add_filter %r{\A/(?:spec|bin)/}
  # Report lib files even when no spec loads them
  track_files "lib/**/*.rb"
  # Loaded by Bundler (through the gemspec) before SimpleCov starts, so it always reads 0%
  add_filter "lib/steam_api_client/version.rb"
  enable_coverage :branch
  # Only in CI: running a single spec file locally would fail the gate
  minimum_coverage line: 98, branch: 95 if ENV["CI"]
end

require "steam_api_client"
require "debug"

# Specs must never reach the network: unstubbed requests raise Typhoeus::Errors::NoStub
Typhoeus::Config.block_connection = true

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
