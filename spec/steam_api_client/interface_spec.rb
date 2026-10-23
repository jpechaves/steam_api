# frozen_string_literal: true

RSpec.describe SteamApiClient do
  it "has a version number" do
    expect(SteamApiClient::VERSION).not_to be nil
  end
end
