require "spec_helper"

RSpec.describe SteamApiClient::Response do
  let(:raw_response) { double("raw_response", status: 200, body: '{"response":{"player_level":"9"}}') }
  let(:endpoint) { SteamApiClient::Endpoints::ALL[:player_level] }
  let(:request) { double("request") }

  subject(:response) { described_class.new(raw_response: raw_response, endpoint: endpoint, request: request) }

  describe "#initialize" do
    it "sets the raw_response, endpoint, and request attributes" do
      expect(response.instance_variable_get(:@raw_response)).to eq(raw_response)
      expect(response.instance_variable_get(:@endpoint)).to eq(endpoint)
      expect(response.request).to eq(request)
    end
  end

  describe "#fail?" do
    it "returns true if the response is not successful" do
      allow(raw_response).to receive(:success?).and_return(false)
      expect(response.fail?).to be true
    end

    it "returns false if the response is successful" do
      allow(raw_response).to receive(:success?).and_return(true)
      expect(response.fail?).to be false
    end
  end

  describe "#status_code" do
    it "returns the HTTP status code" do
      expect(response.status_code).to eq(200)
    end
  end

  describe "#to_h" do
    it "parses the response body as JSON and returns a Hash" do
      expect(response.to_h).to eq({response: {player_level: "9"}})
    end

    it "returns an empty hash if the response body is not JSON" do
      allow(raw_response).to receive(:body).and_return("not json")
      expect(response.to_h).to eq({})
    end
  end

  describe "#json" do
    it "returns Steam's JSON untouched" do
      expect(response.json).to eq({response: {player_level: "9"}})
    end

    it "raises a ResponseParseError when the body isn't a JSON object" do
      allow(raw_response).to receive(:body).and_return("[1]")
      expect { response.json }.to raise_error(SteamApiClient::Errors::ResponseParseError)
    end
  end

  describe "#result" do
    it "builds the endpoint's result" do
      expect(response.result).to eq(9)
    end

    context "when the body has duplicate keys" do
      let(:raw_response) { double("raw_response", status: 200, body: '{"response":{"player_level":1,"player_level":2}}') }

      it "keeps the last value, as Steam's JSON is parsed regardless of the json gem version" do
        expect(response.result).to eq(2)
      end
    end

    context "when the body is not JSON" do
      let(:raw_response) { double("raw_response", status: 200, body: "<html>Oops</html>") }

      it "raises a ResponseParseError caused by the JSON error" do
        expect { response.result }.to raise_error(SteamApiClient::Errors::ResponseParseError) { |error|
          expect(error.cause).to be_a(JSON::ParserError)
          expect(error.response).to eq(response)
        }
      end
    end

    context "when the body is JSON but not an object" do
      let(:raw_response) { double("raw_response", status: 200, body: "[]") }

      it "raises a ResponseParseError" do
        expect { response.result }.to raise_error(SteamApiClient::Errors::ResponseParseError)
      end
    end

    context "when the body does not match the endpoint's result" do
      let(:raw_response) { double("raw_response", status: 200, body: '{"response":{"player_level":"secret_payload"}}') }

      it "raises a ResponseParseError caused by the model error, without the payload in the message" do
        expect { response.result }.to raise_error(SteamApiClient::Errors::ResponseParseError) { |error|
          expect(error.cause).to be_a(SteamApiClient::Model::Error)
          expect(error.message).to include("player_level", "200")
          [error.message, error.cause.message, error.full_message].each { |text| expect(text).not_to include("secret_payload") }
        }
      end
    end
  end
end
