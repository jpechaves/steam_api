require "spec_helper"

RSpec.describe "Network errors" do
  describe SteamApiClient::Errors::HttpTimeout do
    it "can be raised without an HTTP response, when the request timed out" do
      error = described_class.new(nil, "The request to Steam timed out")

      expect(error).to be_a(SteamApiClient::Errors::ApiError)
      expect(error.message).to eq("The request to Steam timed out")
    end
  end

  describe SteamApiClient::Errors::ConnectionError do
    it "is not an ApiError, since there's no HTTP response" do
      expect(described_class.new("Could not connect to Steam")).not_to be_a(SteamApiClient::Errors::ApiError)
    end
  end
end
