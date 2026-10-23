require "spec_helper"

RSpec.describe SteamApiClient::Errors::ResponseParseError do
  let(:response) { instance_double("SteamApiClient::Response", status_code: 200) }

  subject(:error) { described_class.new(response, SteamApiClient::Structs::PlayerLevel) }

  it "exposes the response" do
    expect(error.response).to eq(response)
  end

  it "describes the struct and status code" do
    expect(error.message).to eq(
      "Unable to build SteamApiClient::Structs::PlayerLevel from the API response (status code: 200)"
    )
  end
end
