# frozen_string_literal: true

require "bundler/setup"

require "simplecov"
SimpleCov.start

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
