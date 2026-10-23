require "spec_helper"

RSpec.describe SteamApiClient::Response do
  let(:raw_response) { double("raw_response", code: 200, body: '{"key":"value"}') }
  let(:response_struct) { double("response_struct", build_from_response: {}) }
  let(:request) { double("request") }

  subject(:response) { described_class.new(raw_response: raw_response, response_struct: response_struct, request: request) }

  describe "#initialize" do
    it "sets the raw_response, response_struct, and request attributes" do
      expect(response.instance_variable_get(:@raw_response)).to eq(raw_response)
      expect(response.instance_variable_get(:@response_struct)).to eq(response_struct)
      expect(response.instance_variable_get(:@request)).to eq(request)
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
      expect(response.send(:to_h)).to eq({key: "value"})
    end

    it "returns an empty hash if the response body is not JSON" do
      allow(raw_response).to receive(:body).and_return("not json")
      expect(response.send(:to_h)).to eq({})
    end
  end

  describe "#result" do
    it "calls build_from_response on the response_struct" do
      expect(response_struct).to receive(:build_from_response).with({key: "value"})
      response.result
    end

    context "when the body is not JSON" do
      let(:raw_response) { double("raw_response", code: 200, body: "<html>Oops</html>") }

      it "raises a ResponseParseError caused by the JSON error" do
        expect { response.result }.to raise_error(SteamApiClient::Errors::ResponseParseError) { |error|
          expect(error.cause).to be_a(JSON::ParserError)
          expect(error.response).to eq(response)
        }
      end
    end

    context "when the body is JSON but not an object" do
      let(:raw_response) { double("raw_response", code: 200, body: "[]") }

      it "raises a ResponseParseError" do
        expect { response.result }.to raise_error(SteamApiClient::Errors::ResponseParseError)
      end
    end

    context "when the body does not match the response struct" do
      let(:raw_response) { double("raw_response", code: 200, body: '{"unexpected":{"secret_payload":1}}') }
      let(:response_struct) { SteamApiClient::Structs::PlayerLevel }

      it "raises a ResponseParseError caused by the struct error, without the payload in the message" do
        expect { response.result }.to raise_error(SteamApiClient::Errors::ResponseParseError) { |error|
          expect(error.cause).to be_a(Dry::Struct::Error)
          expect(error.message).to include("SteamApiClient::Structs::PlayerLevel", "200")
          expect(error.message).not_to include("secret_payload")
        }
      end
    end
  end
end
