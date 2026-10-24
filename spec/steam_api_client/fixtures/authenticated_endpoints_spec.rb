require "spec_helper"

# Real responses of the endpoints that need an API key (see spec/fixtures/steam/README.md)
RSpec.describe "Authenticated endpoints, real responses" do
  describe "GetPlayerSummaries" do
    subject(:player) { parse_steam_fixture("player_summaries", :player_summaries).first }

    it "returns the players, as PlayerSummary" do
      expect(parse_steam_fixture("player_summaries", :player_summaries)).to all(be_a(SteamApiClient::PlayerSummary))
    end

    it "parses a public profile" do
      expect(player).to have_attributes(
        steam_id: 76561198000000001, persona_name: "Example Player", community_visibility_state: 3,
        profile_state: 1, persona_state: 0, comment_permission: 1, avatar_full: end_with("_full.jpg")
      )
    end

    it "exposes the extra fields Steam sends for public profiles" do
      expect(player).to have_attributes(
        real_name: "Example Name", time_created: 1262304000, country_code: "US",
        avatar_hash: "0" * 40, primary_clan_id: 103582791400000000, persona_state_flags: 0
      )
    end
  end

  describe "ResolveVanityURL" do
    it "resolves a vanity URL to a SteamID" do
      expect(parse_steam_fixture("player_steamid", :player_steamid)).to eq(76561197960435530)
    end

    it "returns nil for a vanity URL with no match" do
      expect(parse_steam_fixture("player_steamid_no_match", :player_steamid)).to be_nil
    end
  end

  describe "GetFriendList" do
    it "parses friends with integer SteamIDs" do
      friends = parse_steam_fixture("player_friends", :player_friends)

      expect(friends.map(&:steam_id)).to eq([76561198000000002, 76561198000000003, 76561198000000004])
      expect(friends).to all(be_a(SteamApiClient::Friend).and(have_attributes(relationship: "friend", friend_since: 0)))
    end
  end

  describe "GetSteamLevel" do
    it "returns the level" do
      expect(parse_steam_fixture("player_level", :player_level)).to eq(22)
    end
  end

  describe "GetRecentlyPlayedGames" do
    it "parses recently played games" do
      recent = parse_steam_fixture("player_recent_games", :player_recent_games)

      expect(recent).to be_a(SteamApiClient::RecentGames).and(have_attributes(total_count: 1))
      expect(recent.games.first).to have_attributes(app_id: 2868840, playtime_2weeks: 922, playtime_forever: 8357, name: "Slay the Spire 2")
    end

    it "returns nil for a private profile" do
      expect(parse_steam_fixture("player_recent_games_private", :player_recent_games)).to be_nil
    end
  end

  describe "GetPlayerAchievements" do
    it "parses unlocked and locked achievements" do
      stats = parse_steam_fixture("player_achievements", :player_achievements)

      expect(stats).to have_attributes(steam_id: 76561198000000001, game_name: "Team Fortress 2")
      expect(stats.achievements).to all(be_a(SteamApiClient::PlayerAchievements::Achievement))
      expect(stats.achievements.map { |a| [a.api_name, a.achieved] }).to include(["TF_PLAY_GAME_EVERYCLASS", true], ["TF_HEAVY_ACHIEVE_PROGRESS1", false])
    end

    it "raises HttpForbidden with Steam's reason for a private profile" do
      expect { parse_steam_fixture("player_achievements_private", :player_achievements, status: 403) }
        .to raise_error(SteamApiClient::Errors::HttpForbidden, /Profile is not public/)
    end
  end

  describe "GetUserStatsForGame" do
    subject(:stats) { parse_steam_fixture("player_game_stats", :player_game_stats) }

    it "parses the game's achievements" do
      expect(stats).to have_attributes(steam_id: 76561198000000001, game_name: "Team Fortress 2")
      expect(stats.achievements.first).to eq(SteamApiClient::PlayerGameStats::Achievement.new(name: "TF_PLAY_GAME_EVERYCLASS", achieved: true))
    end

    it "exposes the game's stats as name/value pairs" do
      expect(stats.stats.first).to eq(SteamApiClient::PlayerGameStats::Stat.new(name: "Scout.accum.iBuildingsDestroyed", value: 1))
      expect(stats.stats.map(&:value)).to all(be_a(Integer))
    end

    it "raises HttpBadRequest for a private profile (Steam answers 400 with an empty object)" do
      expect { parse_steam_fixture("player_game_stats_private", :player_game_stats, status: 400) }
        .to raise_error(SteamApiClient::Errors::HttpBadRequest)
    end
  end
end
