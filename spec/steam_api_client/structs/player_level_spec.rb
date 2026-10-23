require "spec_helper"

RSpec.describe SteamApiClient::Structs::PlayerLevel do
  subject { described_class.new(params) }

  describe "#initialize" do
    let(:params) { {response: response} }

    context "when the params are present" do
      let(:player_level) { 50 }
      let(:response) { {player_level: player_level} }

      it { is_expected.to have_attributes(response: have_attributes(**response)) }
    end

    context "when the params are missing" do
      let(:response) { {} }

      it { is_expected.to have_attributes(response: have_attributes(player_level: nil)) }
    end
  end
end
