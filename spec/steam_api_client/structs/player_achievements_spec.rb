require "spec_helper"

RSpec.describe SteamApiClient::Structs::PlayerAchievements do
  subject(:instance) { described_class.new(params) }

  describe "#initialize" do
    let(:params) do
      {
        playerstats: {
          steamID: steam_id,
          gameName: game_name,
          success: success,
          achievements: achievements
        }
      }
    end

    context "when the params are present" do
      let(:steam_id) { 76561198160009756 }
      let(:success) { true }
      let(:game_name) { "ELDEN RING" }
      let(:achievements) do
        [
          {apiname: "ACH00", achieved: 1, unlocktime: 1648763893},
          {apiname: "ACH01", achieved: 1, unlocktime: 1647725011}
        ]
      end

      it { is_expected.to have_attributes(playerstats: have_attributes(steamID: steam_id)) }

      it { is_expected.to have_attributes(playerstats: have_attributes(gameName: game_name)) }

      it { is_expected.to have_attributes(playerstats: have_attributes(success: success)) }

      it do
        is_expected.to have_attributes(
          playerstats: have_attributes(
            achievements: contain_exactly(
              have_attributes(**achievements[0]),
              have_attributes(**achievements[1])
            )
          )
        )
      end
    end
  end
end
