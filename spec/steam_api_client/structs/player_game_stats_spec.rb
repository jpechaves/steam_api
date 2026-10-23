require "spec_helper"

RSpec.describe SteamApiClient::Structs::PlayerGameStats do
  subject { described_class.new(params) }

  describe "#initialize" do
    let(:params) do
      {playerstats: {steamID: steam_id, gameName: game_name, achievements: achievements}}
    end

    context "when the params are present" do
      let(:steam_id) { 76561198160009756 }
      let(:game_name) { "ELDEN RING" }
      let(:achievements) do
        [
          {name: "ACH01", achieved: 1},
          {name: "ACH02", achieved: 1},
          {name: "ACH03", achieved: 0}
        ]
      end

      it { is_expected.to have_attributes(playerstats: have_attributes(steamID: steam_id)) }

      it { is_expected.to have_attributes(playerstats: have_attributes(gameName: game_name)) }

      it do
        is_expected.to have_attributes(
          playerstats: have_attributes(
            achievements: contain_exactly(
              have_attributes(**achievements[0]),
              have_attributes(**achievements[1]),
              have_attributes(**achievements[2])
            )
          )
        )
      end
    end
  end

  describe "stats" do
    it "keeps integer and float values as Steam sends them, without truncating floats" do
      struct = described_class.new(playerstats: {stats: [{name: "kills", value: 26580}, {name: "ratio", value: 1.5}]})

      expect(struct.playerstats.stats.map(&:value)).to eq([26580, 1.5])
    end

    it "rejects values that aren't numbers" do
      expect { described_class.new(playerstats: {stats: [{name: "kills", value: "lots"}]}) }.to raise_error(Dry::Struct::Error)
    end
  end
end
