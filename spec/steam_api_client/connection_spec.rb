require "spec_helper"

RSpec.describe "Client connection customization" do
  let(:url) { "https://api.steampowered.com/ISteamUserStats/GetNumberOfCurrentPlayers/v0001/?appid=440" }
  let(:body) { '{"response":{"player_count":5,"result":1}}' }

  # Records the URL of every request, like a logging or instrumentation middleware would
  let(:recorder) do
    Class.new(Faraday::Middleware) do
      def self.urls = (@urls ||= [])

      def on_request(env) = self.class.urls << env.url.to_s
    end
  end

  before { stub_request(:get, url).to_return(status: 200, body: body) }

  it "runs the block given to Client.new on the connection" do
    middleware = recorder
    client = SteamApiClient::Client.new { |faraday| faraday.use middleware }

    client.game_current_players.retrieve(appid: 440)

    expect(middleware.urls).to eq([url])
  end

  it "runs the block set with config.connection on every client" do
    middleware = recorder
    SteamApiClient::Client.configure { |config| config.connection { |faraday| faraday.use middleware } }

    SteamApiClient::Client.new.game_current_players.retrieve(appid: 440)
    SteamApiClient::Client.new.game_current_players.retrieve(appid: 440)

    expect(middleware.urls).to eq([url, url])
  end

  it "runs the global block first, then the client's" do
    calls = []
    SteamApiClient::Client.configure { |config| config.connection { calls << :global } }

    SteamApiClient::Client.new { calls << :client }.connection

    expect(calls).to eq(%i[global client])
  end

  it "lets the block replace the adapter, with its options" do
    stubs = Faraday::Adapter::Test::Stubs.new do |stub|
      stub.get("/ISteamUserStats/GetNumberOfCurrentPlayers/v0001/") { [200, {}, '{"response":{"player_count":7,"result":1}}'] }
    end
    client = SteamApiClient::Client.new { |faraday| faraday.adapter :test, stubs }

    result = client.game_current_players.retrieve(appid: 440)

    expect(result.response.player_count).to eq(7)
    expect(client.connection.builder.adapter).to eq(Faraday::Adapter::Test)
    stubs.verify_stubbed_calls
  end

  it "still uses the configured adapter when the block doesn't set one" do
    client = SteamApiClient::Client.new(adapter: :test) { |faraday| faraday.headers["X-Test"] = "1" }

    expect(client.connection.builder.adapter).to eq(Faraday::Adapter::Test)
    expect(client.connection.headers["X-Test"]).to eq("1")
  end

  it "supports the README's logging recipe, which redacts the API token" do
    require "logger"
    log = StringIO.new
    token_url = "https://api.steampowered.com/IPlayerService/GetSteamLevel/v0001/?key=SECRET-TOKEN-123&steamid=1"
    stub_request(:get, token_url).to_return(status: 200, body: '{"response":{"player_level":1}}')
    client = SteamApiClient::Client.new(api_token: "SECRET-TOKEN-123") do |faraday|
      faraday.response :logger, Logger.new(log), headers: false do |logger|
        logger.filter(/(key=)[^&\s]+/, '\1[REDACTED]')
      end
    end

    client.player_level.retrieve(steamid: 1)

    expect(log.string).to include("GetSteamLevel/v0001/?key=[REDACTED]&steamid=1")
    expect(log.string).not_to include("SECRET-TOKEN-123")
  end

  it "has no connection block by default" do
    expect(SteamApiClient::Client.config.connection).to be_nil
  end
end
