require "spec_helper"
require "pp"

RSpec.describe "API token redaction" do
  let(:token) { "SECRET-TOKEN-123" }
  let(:client) { SteamApiClient::Client.new(api_token: token) }
  let(:url) { "https://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key=#{token}&steamids=123" }
  let(:request) do
    SteamApiClient::Request.new(
      request_struct: SteamApiClient::Structs::Requests::GetPlayerSummaries.new(steamids: [123]),
      response_struct: SteamApiClient::Structs::PlayerSummaries,
      client: client
    )
  end

  def expect_redacted(text)
    expect(text).not_to include(token)
    expect(text).to include("[REDACTED]")
  end

  describe SteamApiClient::Client do
    it "hides the token in #inspect and #pretty_inspect" do
      expect_redacted(client.inspect)
      expect_redacted(client.pretty_inspect)
    end

    it "keeps the other settings visible" do
      expect(client.inspect).to eq(
        "#<SteamApiClient::Client api_token=[REDACTED] timeout=10 connect_timeout=5 adapter=:net_http>"
      )
    end

    it "hides a token set through Client.configure" do
      SteamApiClient::Client.configure { |config| config.api_token = token }

      expect_redacted(SteamApiClient::Client.new.inspect)
    ensure
      SteamApiClient::Client.config.api_token = nil
    end

    it "shows a missing token as nil" do
      expect(SteamApiClient::Client.new.inspect).to include("api_token=nil")
    end
  end

  describe SteamApiClient::Request do
    it "hides the key in the URL" do
      expect(request.inspect).to eq(
        "#<SteamApiClient::Request GET https://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key=[REDACTED]&steamids=123>"
      )
      expect_redacted(request.pretty_inspect)
    end

    it "shows URLs without a key as they are" do
      storefront = SteamApiClient::Request.new(
        request_struct: SteamApiClient::Structs::Requests::GetAppDetails.new(appid: 570, filters: [], cc: "US", l: "en"),
        response_struct: SteamApiClient::Structs::AppDetails::Details,
        client: client
      )

      expect(storefront.inspect).to eq(
        "#<SteamApiClient::Request GET https://store.steampowered.com/api/appdetails/?cc=US&l=en&appids=570&filters=>"
      )
    end
  end

  describe SteamApiClient::Response do
    before { stub_request(:get, url).to_return(status: 200, body: "{}") }

    it "hides the key of the request it holds" do
      response = request.run

      expect(response.inspect).to start_with("#<SteamApiClient::Response status=200 request=#<SteamApiClient::Request GET")
      expect_redacted(response.inspect)
      expect_redacted(response.pretty_inspect)
    end
  end

  describe "errors" do
    it "never show the token, nor through the response they hold" do
      stub_request(:get, url).to_return(status: 403, body: "Forbidden")

      expect { request.run }.to raise_error(SteamApiClient::Errors::HttpForbidden) { |error|
        [error.inspect, error.full_message, error.message].each { |text| expect(text).not_to include(token) }
        # ApiError#response is private, but error trackers can still capture the instance variable
        expect_redacted(error.instance_variable_get(:@response).inspect)
      }
    end

    it "never show the token on parse errors" do
      stub_request(:get, url).to_return(status: 200, body: "not json")

      expect { request.run.result }.to raise_error(SteamApiClient::Errors::ResponseParseError) { |error|
        expect(error.full_message).not_to include(token)
        expect_redacted(error.response.inspect)
      }
    end
  end
end
