require "spec_helper"

RSpec.describe SteamApiClient::Structs::AppGlobalAchievements do
  subject { described_class.new(params) }

  describe "#initialize" do
    let(:params) do
      {achievementpercentages: {achievements: achievements}}
    end

    context "when the params are present" do
      let(:achievements) do
        [
          {name: "TF_DEMOMAN_PARACHUTE_DISTANCE", percent: 5.0},
          {name: "TF_SCOUT_BACKSCATTER_KILL_FRIENDS_GRIND", percent: 5.099999904632568}
        ]
      end

      it do
        is_expected.to have_attributes(
          achievementpercentages: have_attributes(
            achievements: contain_exactly(
              have_attributes(**achievements[0]),
              have_attributes(**achievements[1])
            )
          )
        )
      end
    end
  end

  describe "percent" do
    it "coerces Steam's string percentages to Float" do
      struct = described_class.new(achievementpercentages: {achievements: [{name: "TF_SCOUT_LONG_DISTANCE_RUNNER", percent: "49.6"}]})

      expect(struct.achievementpercentages.achievements.first.percent).to eq(49.6)
    end
  end
end
