require "spec_helper"

RSpec.describe "GetOwnedGames real responses" do
  subject(:result) { parse_steam_fixture(fixture, SteamApiClient::Structs::PlayerOwnedGames) }

  context "with a public library" do
    let(:fixture) { "player_owned_games" }

    it "parses games without per-platform playtimes or rtime_last_played, which Steam doesn't send" do
      expect(result.response.game_count).to eq(375)
      expect(result.response.games.map(&:appid)).to include(440, 10, 2868840)
    end

    it "exposes the optional fields Steam sends" do
      games = result.response.games.to_h { |game| [game.appid, game] }

      expect(games[440]).to have_attributes(name: "Team Fortress 2", has_community_visible_stats: true, has_leaderboards: true)
      expect(games[10]).to have_attributes(content_descriptorids: [2, 5], has_community_visible_stats: nil)
      expect(games[2868840].playtime_2weeks).to be_a(Integer)
      expect(games[10].playtime_windows_forever).to be_nil
    end
  end

  context "with a private library" do
    let(:fixture) { "player_owned_games_private" }

    it "returns an empty response" do
      expect(result.response).to have_attributes(game_count: nil, games: nil)
    end
  end
end
