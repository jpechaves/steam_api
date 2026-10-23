require "spec_helper"

RSpec.describe SteamApiClient::Structs::PlayerRecentGames do
  subject(:instance) { described_class.new(params) }

  describe "#initialize" do
    let(:params) { {response: {total_count: total_count, games: games}} }

    context "when the params are present" do
      let(:total_count) { 10 }
      let(:games) do
        [
          {
            appid: 730,
            name: "Counter-Strike 2",
            playtime_2weeks: 1620,
            playtime_forever: 33229,
            img_icon_url: "8dbc71957312bbd3baea65848b545be9eae2a355"
          },
          {
            appid: 2054970,
            name: "Dragon's Dogma 2",
            playtime_2weeks: 645,
            playtime_forever: 1192,
            img_icon_url: "f3d469e0d7a0e25ddd13db8ebf08f1c24d6478b0"
          }
        ]
      end

      it { is_expected.to have_attributes(response: have_attributes(total_count: total_count)) }

      it do
        is_expected.to have_attributes(
          response: have_attributes(
            games: contain_exactly(
              have_attributes(**games[0]),
              have_attributes(**games[1])
            )
          )
        )
      end
    end

    context "when some params are missing" do
      let(:total_count) {}
      let(:games) {}

      it { is_expected.to have_attributes(response: have_attributes(total_count: nil, games: nil)) }
    end
  end
end
