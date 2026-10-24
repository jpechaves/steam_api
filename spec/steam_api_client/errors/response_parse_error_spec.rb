require "spec_helper"

RSpec.describe SteamApiClient::Errors::ResponseParseError do
  let(:response) { instance_double("SteamApiClient::Response", status_code: 200) }

  subject(:error) { described_class.new(response, SteamApiClient::Endpoints::ALL[:player_level]) }

  it "exposes the response" do
    expect(error.response).to eq(response)
  end

  it "describes the endpoint and status code" do
    expect(error.message).to eq("Unable to read the player_level result from the API response (status code: 200)")
  end
end
