require "spec_helper"

# Real responses of the endpoints that need an API key (see spec/fixtures/steam/README.md)
RSpec.describe "Authenticated endpoints, real responses" do
  structs = SteamApiClient::Structs

  describe "GetPlayerSummaries" do
    it "parses a public profile" do
      player = parse_steam_fixture("player_summaries", structs::PlayerSummaries).response.players.first

      expect(player).to have_attributes(
        steamid: 76561198000000001, personaname: "Example Player", communityvisibilitystate: 3, profilestate: 1, personastate: 0
      )
    end

    it "exposes the extra fields Steam sends for public profiles" do
      player = parse_steam_fixture("player_summaries", structs::PlayerSummaries).response.players.first

      expect(player).to have_attributes(
        realname: "Example Name", timecreated: 1262304000, loccountrycode: "US",
        avatarhash: "0" * 40, primaryclanid: 103582791400000000, personastateflags: 0
      )
    end
  end

  describe "ResolveVanityURL" do
    it "resolves a vanity URL to a SteamID" do
      expect(parse_steam_fixture("player_steamid", structs::PlayerSteamId).response).to have_attributes(steamid: 76561197960435530, success: 1)
    end

    it "reports a vanity URL with no match" do
      expect(parse_steam_fixture("player_steamid_no_match", structs::PlayerSteamId).response).to have_attributes(steamid: nil, success: 42, message: "No match")
    end
  end

  describe "GetFriendList" do
    it "parses friends with integer SteamIDs" do
      friends = parse_steam_fixture("player_friends", structs::PlayerFriends).friendslist.friends

      expect(friends.map(&:steamid)).to eq([76561198000000002, 76561198000000003, 76561198000000004])
      expect(friends).to all(have_attributes(relationship: "friend", friend_since: 0))
    end
  end

  describe "GetSteamLevel" do
    it "parses the level" do
      expect(parse_steam_fixture("player_level", structs::PlayerLevel).response.player_level).to eq(22)
    end
  end

  describe "GetRecentlyPlayedGames" do
    it "parses recently played games" do
      response = parse_steam_fixture("player_recent_games", structs::PlayerRecentGames).response

      expect(response.total_count).to eq(1)
      expect(response.games.first).to have_attributes(appid: 2868840, playtime_2weeks: 922, playtime_forever: 8357)
    end

    it "returns an empty response for a private profile" do
      expect(parse_steam_fixture("player_recent_games_private", structs::PlayerRecentGames).response).to have_attributes(total_count: nil, games: nil)
    end
  end

  describe "GetPlayerAchievements" do
    it "parses unlocked and locked achievements" do
      stats = parse_steam_fixture("player_achievements", structs::PlayerAchievements).playerstats

      expect(stats).to have_attributes(steamID: 76561198000000001, gameName: "Team Fortress 2", success: true)
      expect(stats.achievements.map { |a| [a.apiname, a.achieved] }).to include(["TF_PLAY_GAME_EVERYCLASS", 1], ["TF_HEAVY_ACHIEVE_PROGRESS1", 0])
    end

    it "raises HttpForbidden with Steam's reason for a private profile" do
      expect { parse_steam_fixture("player_achievements_private", structs::PlayerAchievements, status: 403) }
        .to raise_error(SteamApiClient::Errors::HttpForbidden, /Profile is not public/)
    end
  end

  describe "GetUserStatsForGame" do
    it "parses the game's achievements" do
      stats = parse_steam_fixture("player_game_stats", structs::PlayerGameStats).playerstats

      expect(stats).to have_attributes(steamID: 76561198000000001, gameName: "Team Fortress 2")
      expect(stats.achievements.map(&:name)).to include("TF_PLAY_GAME_EVERYCLASS")
    end

    it "exposes the game's stats as name/value pairs" do
      stats = parse_steam_fixture("player_game_stats", structs::PlayerGameStats).playerstats.stats

      expect(stats.first).to have_attributes(name: "Scout.accum.iBuildingsDestroyed", value: 1)
      expect(stats.map(&:value)).to all(be_a(Integer))
    end

    it "raises HttpBadRequest for a private profile (Steam answers 400 with an empty object)" do
      expect { parse_steam_fixture("player_game_stats_private", structs::PlayerGameStats, status: 400) }
        .to raise_error(SteamApiClient::Errors::HttpBadRequest)
    end
  end
end
