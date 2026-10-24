require "spec_helper"

RSpec.describe SteamApiClient::Request do
  let(:endpoint) { SteamApiClient::Endpoints::ALL[:player_summaries] }
  let(:params) { {steamids: [123]} }
  let(:client) do
    SteamApiClient::Client.new(api_token: "test_api_key")
  end

  subject(:request) { described_class.new(endpoint: endpoint, params: params, client: client) }

  let(:url) { "https://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key=test_api_key&steamids=123" }

  describe "#initialize" do
    it "builds the full Web API URL as a String, with the key first" do
      expect(request.send(:url)).to eq(url)
    end

    context "with a Storefront endpoint" do
      let(:endpoint) { SteamApiClient::Endpoints::ALL[:app_details] }
      let(:params) { {appid: 123} }

      it "builds the Storefront URL, without the key" do
        expect(request.send(:url)).to eq("https://store.steampowered.com/api/appdetails/?appids=123&filters=&cc=US&l=en")
      end
    end

    it "checks the params before anything else" do
      expect { described_class.new(endpoint: endpoint, params: {}, client: SteamApiClient::Client.new) }
        .to raise_error(ArgumentError, "missing keyword: :steamids")
    end

    it "raises MissingApiToken when the endpoint needs a key and the client has none" do
      expect { described_class.new(endpoint: endpoint, params: params, client: SteamApiClient::Client.new) }
        .to raise_error(SteamApiClient::Errors::MissingApiToken)
    end
  end

  describe "#run" do
    before { stub_request(:get, url).to_return(status: 200, body: "{}") }

    it "executes the request and returns a checked response" do
      allow(SteamApiClient::FailureHandler.instance).to receive(:call).and_call_original

      response = request.run

      expect(response).to be_a(SteamApiClient::Response)
      expect(response.status_code).to eq(200)
      expect(SteamApiClient::FailureHandler.instance).to have_received(:call).with(response)
    end

    it "builds the response with the endpoint" do
      expect(request.run.send(:endpoint)).to be(endpoint)
    end

    it "sends a GET without a body or a JSON content type" do
      stub = stub_request(:get, url).with { |req| req.body.to_s.empty? && !req.headers.key?("Content-Type") }

      request.run

      expect(stub).to have_been_requested
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
end
