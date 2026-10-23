require "spec_helper"

RSpec.describe SteamApiClient::Structs::PlayerOwnedGames do
  subject(:instance) { described_class.new(params) }

  describe "#initialize" do
    let(:params) { {response: {game_count: game_count, games: games}} }

    context "when the params are present" do
      let(:game_count) { 333 }
      let(:games) do
        [
          {
            appid: 300,
            name: "Day of Defeat: Source",
            playtime_forever: 0,
            img_icon_url: "062754bb5853b0534283ae27dc5d58200692b22d",
            playtime_windows_forever: 0,
            playtime_mac_forever: 0,
            playtime_linux_forever: 0,
            rtime_last_played: 0
          },
          {
            appid: 620,
            name: "Portal 2",
            playtime_forever: 634,
            img_icon_url: "2e478fc6874d06ae5baf0d147f6f21203291aa02",
            playtime_windows_forever: 632,
            playtime_mac_forever: 0,
            playtime_linux_forever: 1,
            rtime_last_played: 1657393559
          }
        ]
      end

      it { is_expected.to have_attributes(response: have_attributes(game_count: game_count)) }

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
      let(:game_count) { 666 }
      let(:games) do
        [
          {
            appid: 300,
            playtime_forever: 0,
            playtime_windows_forever: 0,
            playtime_mac_forever: 0,
            playtime_linux_forever: 0,
            rtime_last_played: 0
          },
          {appid: 620,
           playtime_forever: 634,
           playtime_windows_forever: 632,
           playtime_mac_forever: 0,
           playtime_linux_forever: 1,
           rtime_last_played: 1657393559}
        ]
      end

      it { is_expected.to have_attributes(response: have_attributes(game_count: game_count)) }

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
  end
end
