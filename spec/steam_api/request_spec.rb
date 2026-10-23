require "spec_helper"
require "typhoeus"

RSpec.describe SteamApi::Request do
  let(:request_struct) do
    SteamApi::Structs::Requests::GetPlayerSummaries.new(steamids: [123])
  end

  let(:response_struct) { SteamApi::Structs::PlayerSummaries }
  let(:client) do
    SteamApi::Client.new(api_token: "test_api_key")
  end

  subject(:request) { described_class.new(request_struct: request_struct, response_struct: response_struct, client: client) }

  describe "#initialize" do
    it "builds the request without errors" do
      expect { request }.not_to raise_error
    end
  end

  describe "#run" do
    let(:raw_response) { instance_double("Typhoeus::Response", body: "{}", code: 200) }

    before do
      allow(Typhoeus::Request).to receive(:new).and_return(instance_double("Typhoeus::Request", run: raw_response))
      allow(SteamApi::FailureHandler.instance).to receive(:call)
    end

    it "executes the request and returns a response" do
      response = request.run

      expect(response).to be_a(SteamApi::Response)
      expect(SteamApi::FailureHandler.instance).to have_received(:call).with(response)
    end
  end

  describe "timeouts" do
    let(:client) { SteamApi::Client.new(api_token: "test_api_key", timeout: 1.5, connect_timeout: 0.25) }

    it "passes the client's timeouts to Typhoeus in milliseconds" do
      expect(request.send(:raw_request).options).to include(timeout_ms: 1500, connecttimeout_ms: 250, nosignal: true)
    end

    context "when the request times out" do
      before do
        timed_out = Typhoeus::Response.new(return_code: :operation_timedout, response_code: 0)
        Typhoeus.stub(/api.steampowered.com/).and_return(timed_out)
      end

      after { Typhoeus::Expectation.clear }

      it "raises an HttpTimeout error" do
        expect { request.run }.to raise_error(SteamApi::Errors::HttpTimeout)
      end
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
        SteamApi::Structs::Requests::GetAppDetails.new(appid: 123, filters: [], cc: "US", l: "en")
      end

      it "constructs the correct storefront URL" do
        url = request.send(:build_storefront_url)
        expect(url.to_s).to eq("https://store.steampowered.com/api/appdetails/?cc=US&l=en&appids=123&filters=")
      end
    end
  end
end
