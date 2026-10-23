require "spec_helper"

RSpec.describe SteamApiClient::Structs::GameCurrentPlayers do
  subject { described_class.new(params) }

  describe "#initialize" do
    let(:params) do
      {response: {player_count: player_count, result: result}}
    end

    context "when the params are present" do
      let(:player_count) { 90356 }
      let(:result) { 1 }

      it { is_expected.to have_attributes(response: have_attributes(player_count: player_count)) }

      it { is_expected.to have_attributes(response: have_attributes(result: result)) }
    end
  end
end
