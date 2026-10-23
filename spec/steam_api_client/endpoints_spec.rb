require "spec_helper"

# Calls every endpoint through the client against a Typhoeus stub registered
# for the exact URL Steam documents. Real connections are blocked in
# spec_helper, so a wrong interface, method, version, query param or API key
# fails with Typhoeus::Errors::NoStub.
#
# List params are comma-joined and sent percent-encoded (%2C), which Steam
# decodes the same as a literal comma.
RSpec.describe "Steam API endpoints" do
  let(:client) { SteamApiClient::Client.new(api_token: "test-key") }
  let(:web_api) { "https://api.steampowered.com" }
  let(:store_api) { "https://store.steampowered.com/api" }

  after { Typhoeus::Expectation.clear }

  def stub_steam(url, body)
    Typhoeus.stub(url).and_return(Typhoeus::Response.new(code: 200, body: body.to_json))
  end

  describe "#player_summaries" do
    it "calls ISteamUser/GetPlayerSummaries/v0002 with comma-separated steamids" do
      stub_steam("#{web_api}/ISteamUser/GetPlayerSummaries/v0002/?key=test-key&steamids=76561197960435530%2C76561197960265731", {
        response: {players: [{
          steamid: "76561197960435530", personaname: "Robin", profileurl: "https://steamcommunity.com/id/robinwalker/",
          avatar: "a.jpg", avatarmedium: "a_medium.jpg", avatarfull: "a_full.jpg",
          personastate: 0, communityvisibilitystate: 3, profilestate: 1
        }]}
      })

      result = client.player_summaries.retrieve([76561197960435530, 76561197960265731])

      expect(result.response.players.first).to have_attributes(steamid: "76561197960435530", personaname: "Robin")
    end
  end

  describe "#player_steamid" do
    it "calls ISteamUser/ResolveVanityURL/v0001" do
      stub_steam("#{web_api}/ISteamUser/ResolveVanityURL/v0001/?key=test-key&vanityurl=gabelogannewell",
        {response: {steamid: "76561197960287930", success: 1}})

      expect(client.player_steamid.retrieve("gabelogannewell").response).to have_attributes(steamid: 76561197960287930, success: 1)
    end
  end

  describe "#player_friends" do
    it "calls ISteamUser/GetFriendList/v0001 with the relationship (all by default)" do
      stub_steam("#{web_api}/ISteamUser/GetFriendList/v0001/?key=test-key&steamid=76561197960435530&relationship=all",
        {friendslist: {friends: [{steamid: "76561197960265731", relationship: "friend", friend_since: 0}]}})

      expect(client.player_friends.retrieve(76561197960435530).friendslist.friends.first).to have_attributes(relationship: "friend")
    end
  end

  describe "#player_level" do
    it "calls IPlayerService/GetSteamLevel/v0001" do
      stub_steam("#{web_api}/IPlayerService/GetSteamLevel/v0001/?key=test-key&steamid=76561197960435530",
        {response: {player_level: 42}})

      expect(client.player_level.retrieve(76561197960435530).response.player_level).to eq(42)
    end
  end

  describe "#player_owned_games" do
    it "calls IPlayerService/GetOwnedGames/v0001 with the include_* flags" do
      stub_steam("#{web_api}/IPlayerService/GetOwnedGames/v0001/?key=test-key&steamid=76561197960435530&include_appinfo=true&include_played_free_games=false", {
        response: {game_count: 1, games: [{
          appid: 440, name: "Team Fortress 2", playtime_forever: 120, img_icon_url: "icon",
          playtime_windows_forever: 120, playtime_mac_forever: 0, playtime_linux_forever: 0, rtime_last_played: 1700000000
        }]}
      })

      result = client.player_owned_games.retrieve(76561197960435530, include_appinfo: true)

      expect(result.response).to have_attributes(game_count: 1, games: [have_attributes(appid: 440, name: "Team Fortress 2")])
    end
  end

  describe "#player_recent_games" do
    it "calls IPlayerService/GetRecentlyPlayedGames/v0001 with count (5 by default)" do
      stub_steam("#{web_api}/IPlayerService/GetRecentlyPlayedGames/v0001/?key=test-key&steamid=76561197960435530&count=5", {
        response: {total_count: 1, games: [{appid: 570, name: "Dota 2", playtime_2weeks: 60, playtime_forever: 600, img_icon_url: "icon"}]}
      })

      expect(client.player_recent_games.retrieve(76561197960435530).response.games.first).to have_attributes(appid: 570, playtime_2weeks: 60)
    end
  end

  describe "#player_achievements" do
    it "calls ISteamUserStats/GetPlayerAchievements/v0001" do
      stub_steam("#{web_api}/ISteamUserStats/GetPlayerAchievements/v0001/?key=test-key&appid=440&steamid=76561197960435530", {
        playerstats: {steamID: "76561197960435530", gameName: "Team Fortress 2", success: true,
                      achievements: [{apiname: "TF_PLAY_GAME_EVERYCLASS", achieved: 1, unlocktime: 1700000000}]}
      })

      result = client.player_achievements.retrieve(440, 76561197960435530)

      expect(result.playerstats).to have_attributes(success: true, achievements: [have_attributes(apiname: "TF_PLAY_GAME_EVERYCLASS")])
    end
  end

  describe "#player_game_stats" do
    it "calls ISteamUserStats/GetUserStatsForGame/v0002" do
      stub_steam("#{web_api}/ISteamUserStats/GetUserStatsForGame/v0002/?key=test-key&appid=440&steamid=76561197960435530", {
        playerstats: {steamID: "76561197960435530", gameName: "Team Fortress 2", achievements: [{name: "TF_PLAY_GAME_EVERYCLASS", achieved: 1}]}
      })

      expect(client.player_game_stats.retrieve(440, 76561197960435530).playerstats).to have_attributes(gameName: "Team Fortress 2")
    end
  end

  describe "#app_news" do
    it "calls ISteamNews/GetNewsForApp/v0002 without the API key" do
      stub_steam("#{web_api}/ISteamNews/GetNewsForApp/v0002/?appid=440&count=2&maxlength=300", {
        appnews: {appid: 440, count: 1, newsitems: [{
          gid: "1", title: "Update", url: "https://example.com", is_external_url: false, author: "Valve",
          contents: "Notes", feedlabel: "Community", date: 1700000000, feedname: "steam_community", feed_type: 1, appid: 440
        }]}
      })

      expect(client.app_news.retrieve(440, 2).appnews.newsitems.first).to have_attributes(title: "Update")
    end
  end

  describe "#app_global_achievements" do
    it "calls ISteamUserStats/GetGlobalAchievementPercentagesForApp/v0002 without the API key" do
      stub_steam("#{web_api}/ISteamUserStats/GetGlobalAchievementPercentagesForApp/v0002/?gameid=440",
        {achievementpercentages: {achievements: [{name: "TF_SCOUT_LONG_DISTANCE_RUNNER", percent: "49.6"}]}})

      expect(client.app_global_achievements.retrieve(440).achievementpercentages.achievements.first).to have_attributes(name: "TF_SCOUT_LONG_DISTANCE_RUNNER")
    end
  end

  describe "#game_current_players" do
    it "calls ISteamUserStats/GetNumberOfCurrentPlayers/v0001 without the API key" do
      stub_steam("#{web_api}/ISteamUserStats/GetNumberOfCurrentPlayers/v0001/?appid=440", {response: {player_count: 83494, result: 1}})

      expect(client.game_current_players.retrieve(440).response).to have_attributes(player_count: 83494, result: 1)
    end
  end

  describe "#app_details" do
    it "calls the Storefront appdetails endpoint with filters, country code and language, without the API key" do
      stub_steam("#{store_api}/appdetails/?cc=BR&l=pt&appids=570&filters=basic%2Cprice_overview",
        {"570": {success: true, data: {type: "game", name: "Dota 2", is_free: true}}})

      result = client.app_details.retrieve(appid: 570, filters: ["basic", "price_overview"], country_code: "BR", locale: "pt")

      expect(result).to have_attributes(appid: 570, response: have_attributes(success: true, data: have_attributes(name: "Dota 2")))
    end
  end
end
