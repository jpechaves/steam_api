require "spec_helper"

# Calls every endpoint through the client against a WebMock stub registered
# for the exact URL Steam documents. Real connections are blocked in
# spec_helper, so a wrong interface, method, version, query param or API key
# fails with WebMock::NetConnectNotAllowedError.
#
# List params are comma-joined and sent percent-encoded (%2C), which Steam
# decodes the same as a literal comma.
RSpec.describe "Steam API endpoints" do
  let(:client) { SteamApiClient::Client.new(api_token: "test-key") }
  let(:web_api) { "https://api.steampowered.com" }
  let(:store_api) { "https://store.steampowered.com/api" }

  def stub_steam(url, body)
    stub_request(:get, url).to_return(status: 200, body: body.to_json)
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

      result = client.player_summaries.retrieve(steamids: [76561197960435530, 76561197960265731])

      expect(result).to contain_exactly(have_attributes(steam_id: 76561197960435530, persona_name: "Robin"))
    end
  end

  describe "#player_steamid" do
    it "calls ISteamUser/ResolveVanityURL/v0001" do
      stub_steam("#{web_api}/ISteamUser/ResolveVanityURL/v0001/?key=test-key&vanityurl=gabelogannewell",
        {response: {steamid: "76561197960287930", success: 1}})

      expect(client.player_steamid.retrieve(vanityurl: "gabelogannewell")).to eq(76561197960287930)
    end
  end

  describe "#player_friends" do
    it "calls ISteamUser/GetFriendList/v0001 with the relationship (all by default)" do
      stub_steam("#{web_api}/ISteamUser/GetFriendList/v0001/?key=test-key&steamid=76561197960435530&relationship=all",
        {friendslist: {friends: [{steamid: "76561197960265731", relationship: "friend", friend_since: 0}]}})

      expect(client.player_friends.retrieve(steamid: 76561197960435530)).to eq([SteamApiClient::Friend.new(steam_id: 76561197960265731, relationship: "friend", friend_since: 0)])
    end
  end

  describe "#player_level" do
    it "calls IPlayerService/GetSteamLevel/v0001" do
      stub_steam("#{web_api}/IPlayerService/GetSteamLevel/v0001/?key=test-key&steamid=76561197960435530",
        {response: {player_level: 42}})

      expect(client.player_level.retrieve(steamid: 76561197960435530)).to eq(42)
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

      result = client.player_owned_games.retrieve(steamid: 76561197960435530, include_appinfo: true)

      expect(result).to have_attributes(game_count: 1, games: [have_attributes(app_id: 440, name: "Team Fortress 2", rtime_last_played: 1700000000)])
    end
  end

  describe "#player_recent_games" do
    it "calls IPlayerService/GetRecentlyPlayedGames/v0001 with count (5 by default)" do
      stub_steam("#{web_api}/IPlayerService/GetRecentlyPlayedGames/v0001/?key=test-key&steamid=76561197960435530&count=5", {
        response: {total_count: 1, games: [{appid: 570, name: "Dota 2", playtime_2weeks: 60, playtime_forever: 600, img_icon_url: "icon"}]}
      })

      expect(client.player_recent_games.retrieve(steamid: 76561197960435530).games.first).to have_attributes(app_id: 570, playtime_2weeks: 60)
    end
  end

  describe "#player_achievements" do
    it "calls ISteamUserStats/GetPlayerAchievements/v0001" do
      stub_steam("#{web_api}/ISteamUserStats/GetPlayerAchievements/v0001/?key=test-key&appid=440&steamid=76561197960435530", {
        playerstats: {steamID: "76561197960435530", gameName: "Team Fortress 2", success: true,
                      achievements: [{apiname: "TF_PLAY_GAME_EVERYCLASS", achieved: 1, unlocktime: 1700000000}]}
      })

      result = client.player_achievements.retrieve(appid: 440, steamid: 76561197960435530)

      expect(result).to have_attributes(game_name: "Team Fortress 2", achievements: [have_attributes(api_name: "TF_PLAY_GAME_EVERYCLASS", achieved: true)])
    end
  end

  describe "#player_game_stats" do
    it "calls ISteamUserStats/GetUserStatsForGame/v0002" do
      stub_steam("#{web_api}/ISteamUserStats/GetUserStatsForGame/v0002/?key=test-key&appid=440&steamid=76561197960435530", {
        playerstats: {steamID: "76561197960435530", gameName: "Team Fortress 2", achievements: [{name: "TF_PLAY_GAME_EVERYCLASS", achieved: 1}]}
      })

      expect(client.player_game_stats.retrieve(appid: 440, steamid: 76561197960435530)).to have_attributes(game_name: "Team Fortress 2", steam_id: 76561197960435530)
    end
  end

  describe "#player_wishlist" do
    it "calls IWishlistService/GetWishlist/v1 without the API key" do
      stub_steam("#{web_api}/IWishlistService/GetWishlist/v1/?steamid=76561197960435530",
        {response: {items: [{appid: 440, priority: 1, date_added: 1700000000}]}})

      expect(client.player_wishlist.retrieve(steamid: 76561197960435530)).to eq([SteamApiClient::WishlistItem.new(app_id: 440, priority: 1, date_added: 1700000000)])
    end
  end

  describe "#player_wishlist_count" do
    it "calls IWishlistService/GetWishlistItemCount/v1 without the API key" do
      stub_steam("#{web_api}/IWishlistService/GetWishlistItemCount/v1/?steamid=76561197960435530", {response: {count: 19}})

      expect(client.player_wishlist_count.retrieve(steamid: 76561197960435530)).to eq(19)
    end
  end

  describe "#player_followed_games" do
    it "calls IStoreService/GetGamesFollowed/v1 without the API key" do
      stub_steam("#{web_api}/IStoreService/GetGamesFollowed/v1/?steamid=76561197960435530", {response: {appids: [400, 440]}})

      expect(client.player_followed_games.retrieve(steamid: 76561197960435530)).to eq([400, 440])
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

      expect(client.app_news.retrieve(appid: 440, count: 2)).to contain_exactly(have_attributes(title: "Update", feed_label: "Community", app_id: 440))
    end
  end

  describe "#app_global_achievements" do
    it "calls ISteamUserStats/GetGlobalAchievementPercentagesForApp/v0002 without the API key" do
      stub_steam("#{web_api}/ISteamUserStats/GetGlobalAchievementPercentagesForApp/v0002/?gameid=440",
        {achievementpercentages: {achievements: [{name: "TF_SCOUT_LONG_DISTANCE_RUNNER", percent: "49.6"}]}})

      expect(client.app_global_achievements.retrieve(appid: 440)).to eq([SteamApiClient::GlobalAchievement.new(name: "TF_SCOUT_LONG_DISTANCE_RUNNER", percent: 49.6)])
    end
  end

  describe "#game_current_players" do
    it "calls ISteamUserStats/GetNumberOfCurrentPlayers/v0001 without the API key" do
      stub_steam("#{web_api}/ISteamUserStats/GetNumberOfCurrentPlayers/v0001/?appid=440", {response: {player_count: 83494, result: 1}})

      expect(client.game_current_players.retrieve(appid: 440)).to eq(83494)
    end
  end

  describe "#app_details" do
    it "calls the Storefront appdetails endpoint with filters, country code and language, without the API key" do
      stub_steam("#{store_api}/appdetails/?cc=BR&l=pt&appids=570&filters=basic%2Cprice_overview",
        {"570": {success: true, data: {type: "game", name: "Dota 2", is_free: true}}})

      result = client.app_details.retrieve(appid: 570, filters: ["basic", "price_overview"], country_code: "BR", locale: "pt")

      expect(result).to be_a(SteamApiClient::AppDetails).and(have_attributes(app_id: 570, name: "Dota 2", is_free: true))
    end
  end

  describe "#package_details" do
    it "calls the Storefront packagedetails endpoint with country code and language, without the API key" do
      stub_steam("#{store_api}/packagedetails/?packageids=469&cc=BR&l=pt",
        {"469": {success: true, data: {name: "The Orange Box", apps: [{id: 440, name: "Team Fortress 2"}]}}})

      result = client.package_details.retrieve(packageid: 469, country_code: "BR", locale: "pt")

      expect(result).to be_a(SteamApiClient::PackageDetails).and(have_attributes(package_id: 469, name: "The Orange Box"))
    end
  end

  describe "#app_dlc" do
    it "calls the Storefront dlcforapp endpoint (US and English by default), without the API key" do
      stub_steam("#{store_api}/dlcforapp/?appid=440&cc=US&l=en",
        {status: 1, appid: "440", name: "Team Fortress 2", dlc: [{id: 629330, name: "Fight Songs"}]})

      expect(client.app_dlc.retrieve(appid: 440)).to have_attributes(app_id: 440, dlc: [have_attributes(id: 629330, name: "Fight Songs")])
    end
  end

  describe "#store_search" do
    it "calls the Storefront storesearch endpoint with the term encoded, without the API key" do
      stub_steam("#{store_api}/storesearch/?term=half%20life&cc=US&l=en",
        {total: 1, items: [{type: "app", name: "Half-Life", id: 70, metascore: "96"}]})

      expect(client.store_search.retrieve(term: "half life")).to contain_exactly(have_attributes(id: 70, name: "Half-Life", metascore: 96))
    end
  end

  describe "#retrieve_raw" do
    it "returns Steam's JSON untouched" do
      stub_steam("#{web_api}/IPlayerService/GetSteamLevel/v0001/?key=test-key&steamid=76561197960435530",
        {response: {player_level: 42, new_field: "x"}})

      expect(client.player_level.retrieve_raw(steamid: 76561197960435530)).to eq(response: {player_level: 42, new_field: "x"})
    end

    it "raises ResponseParseError when the body isn't a JSON object" do
      stub_request(:get, "#{web_api}/ISteamUserStats/GetNumberOfCurrentPlayers/v0001/?appid=440").to_return(status: 200, body: "[]")

      expect { client.game_current_players.retrieve_raw(appid: 440) }.to raise_error(SteamApiClient::Errors::ResponseParseError)
    end
  end

  describe "empty results" do
    it "returns [] for lists Steam leaves out" do
      stub_steam("#{web_api}/ISteamUser/GetFriendList/v0001/?key=test-key&steamid=1&relationship=all", {friendslist: {}})

      expect(client.player_friends.retrieve(steamid: 1)).to eq([])
    end

    it "returns nil for an unavailable app" do
      stub_steam("#{store_api}/appdetails/?appids=1&filters=&cc=US&l=en", {"1": {success: false}})

      expect(client.app_details.retrieve(appid: 1)).to be_nil
    end

    it "returns nil when the profile isn't visible (Steam sends an empty object)" do
      stub_steam("#{web_api}/IPlayerService/GetSteamLevel/v0001/?key=test-key&steamid=1", {response: {}})

      expect(client.player_level.retrieve(steamid: 1)).to be_nil
    end
  end

  describe "rate limiting" do
    it "raises HttpTooManyRequests with the Retry-After delay" do
      stub_request(:get, "#{web_api}/ISteamUserStats/GetNumberOfCurrentPlayers/v0001/?appid=440")
        .to_return(status: 429, body: "Too Many Requests", headers: {"Retry-After" => "30"})

      expect { client.game_current_players.retrieve(appid: 440) }.to raise_error(SteamApiClient::Errors::HttpTooManyRequests) { |error|
        expect(error.retry_after).to eq(30)
      }
    end
  end

  describe "network failures" do
    let(:url) { "#{web_api}/ISteamUserStats/GetNumberOfCurrentPlayers/v0001/?appid=440" }

    it "raises HttpTimeout when Steam doesn't answer in time" do
      stub_request(:get, url).to_raise(Net::ReadTimeout)

      expect { client.game_current_players.retrieve(appid: 440) }.to raise_error(SteamApiClient::Errors::HttpTimeout, /timed out/) { |error|
        expect(error.cause).to be_a(Faraday::TimeoutError)
      }
    end

    it "raises HttpTimeout when the connection can't be opened in time" do
      stub_request(:get, url).to_timeout

      expect { client.game_current_players.retrieve(appid: 440) }.to raise_error(SteamApiClient::Errors::HttpTimeout)
    end

    it "raises ConnectionError when Steam can't be reached" do
      stub_request(:get, url).to_raise(Errno::ECONNREFUSED)

      expect { client.game_current_players.retrieve(appid: 440) }.to raise_error(SteamApiClient::Errors::ConnectionError, /Could not connect to Steam/) { |error|
        expect(error.cause).to be_a(Faraday::ConnectionFailed)
      }
    end

    it "raises ConnectionError on TLS errors" do
      stub_request(:get, url).to_raise(OpenSSL::SSL::SSLError)

      expect { client.game_current_players.retrieve(appid: 440) }.to raise_error(SteamApiClient::Errors::ConnectionError)
    end
  end

  describe "invalid data" do
    it "raises ResponseParseError when a value can't be coerced to its declared type" do
      stub_steam("#{web_api}/IPlayerService/GetSteamLevel/v0001/?key=test-key&steamid=76561197960435530",
        {response: {player_level: "not a number"}})

      expect { client.player_level.retrieve(steamid: 76561197960435530) }.to raise_error(SteamApiClient::Errors::ResponseParseError)
    end
  end

  describe "arguments" do
    it "requires keyword arguments, so IDs can't be swapped by position" do
      expect { client.player_achievements.retrieve(440, 76561197960435530) }.to raise_error(ArgumentError)
      expect { client.player_achievements.retrieve(appid: 440) }.to raise_error(ArgumentError, /missing keyword: :steamid/)
    end
  end

  describe "API token" do
    [nil, ""].each do |token|
      context "when the client has no token (#{token.inspect})" do
        let(:client) { SteamApiClient::Client.new(api_token: token) }

        it "raises MissingApiToken for endpoints that need one, before any request" do
          expect { client.player_level.retrieve(steamid: 76561197960435530) }
            .to raise_error(SteamApiClient::Errors::MissingApiToken, /Client\.configure/)
        end

        it "still calls endpoints that don't need one" do
          stub_steam("#{web_api}/ISteamUserStats/GetNumberOfCurrentPlayers/v0001/?appid=440", {response: {player_count: 1, result: 1}})

          expect(client.game_current_players.retrieve(appid: 440)).to eq(1)
        end
      end
    end
  end
end
