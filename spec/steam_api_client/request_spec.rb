require "spec_helper"

RSpec.describe SteamApiClient::Request do
  let(:request_struct) do
    SteamApiClient::Structs::Requests::GetPlayerSummaries.new(steamids: [123])
  end

  let(:response_struct) { SteamApiClient::Structs::PlayerSummaries }
  let(:client) do
    SteamApiClient::Client.new(api_token: "test_api_key")
  end

  subject(:request) { described_class.new(request_struct: request_struct, response_struct: response_struct, client: client) }

  describe "#initialize" do
    it "builds the request without errors" do
      expect { request }.not_to raise_error
    end

    it "builds the full URL as a String" do
      expect(request.send(:url)).to eq(
        "https://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key=test_api_key&steamids=123"
      )
    end
  end

  let(:url) { "https://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key=test_api_key&steamids=123" }

  describe "#run" do
    before { stub_request(:get, url).to_return(status: 200, body: "{}") }

    it "executes the request and returns a checked response" do
      allow(SteamApiClient::FailureHandler.instance).to receive(:call).and_call_original

      response = request.run

      expect(response).to be_a(SteamApiClient::Response)
      expect(response.status_code).to eq(200)
      expect(SteamApiClient::FailureHandler.instance).to have_received(:call).with(response)
    end
  end

  describe "body" do
    it "sends GET requests without a body or a JSON content type" do
      stub = stub_request(:get, url).with { |req| req.body.to_s.empty? && !req.headers.key?("Content-Type") }

      request.run

      expect(stub).to have_been_requested
    end

    context "when the request isn't a GET" do
      let(:request_struct) do
        Class.new(SteamApiClient::Structs::Requests::GetPlayerSummaries) do
          def method = :post

          def body = {steamids: steamids}
        end.new(steamids: [123])
      end

      it "sends the struct's body as JSON" do
        stub = stub_request(:post, url).with(body: '{"steamids":[123]}', headers: {"Content-Type" => "application/json"})

        request.run

        expect(stub).to have_been_requested
      end
    end
  end

  describe "timeouts" do
    let(:client) { SteamApiClient::Client.new(api_token: "test_api_key", timeout: 1.5, connect_timeout: 0.25) }

    it "passes the client's timeouts to Faraday in seconds" do
      expect(request.send(:request_options)).to eq(timeout: 1.5, open_timeout: 0.25)
    end

    it "applies them to the Faraday request" do
      stub_request(:get, url).to_return(status: 200, body: "{}")
      options = nil
      allow(client.connection).to receive(:run_request).and_wrap_original do |original, *args, &block|
        original.call(*args) do |req|
          block.call(req)
          options = req.options
        end
      end

      request.run

      expect(options).to have_attributes(timeout: 1.5, open_timeout: 0.25)
    end
  end

  describe "private methods" do
    describe "#build_base_url" do
      it "constructs the correct base URL" do
        url = request.send(:build_base_url)
        expect(url.to_s).to eq("https://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key=test_api_key&steamids=123")
      end
    end

    describe "#build_storefront_url" do
      let(:request_struct) do
        SteamApiClient::Structs::Requests::GetAppDetails.new(appid: 123, filters: [], cc: "US", l: "en")
      end

      it "constructs the correct storefront URL" do
        url = request.send(:build_storefront_url)
        expect(url.to_s).to eq("https://store.steampowered.com/api/appdetails/?cc=US&l=en&appids=123&filters=")
      end
    end
  end
end
