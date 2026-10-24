# frozen_string_literal: true

require "bundler/setup"

require "simplecov"
SimpleCov.start do
  # Measure the gem only (lib/), including files no spec loads
  cover "lib/**/*.rb"
  # Loaded by Bundler (through the gemspec) before SimpleCov starts, so it always reads 0%
  skip "lib/steam_api_client/version.rb"
  enable_coverage :branch
  # Only in CI: running a single spec file locally would fail the gate
  minimum_coverage line: 98, branch: 95 if ENV["CI"]
end

require "steam_api_client"
require "debug"

require "webmock/rspec"

# Specs must never reach the network: unstubbed requests raise WebMock::NetConnectNotAllowedError
WebMock.disable_net_connect!

Dir[File.expand_path("support/**/*.rb", __dir__)].sort.each { |file| require file }

RSpec.configure do |config|
  config.include SteamFixtures
  # Client.configure is global: start every example from the defaults
  config.after { SteamApiClient::Client.reset_config! }
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
