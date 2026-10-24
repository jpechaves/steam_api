module SteamApiClient
  # Every endpoint the client exposes, as `client.<name>.retrieve(**params)`.
  #
  # Web API paths are "<interface>/<method>/<version>/" under https://api.steampowered.com.
  # Storefront paths (`api: :store`) are relative to https://store.steampowered.com/api/,
  # Steam's unofficial store API.
  #
  # To add an endpoint, declare it here and write its response struct.
  module Endpoints
    param = Endpoint::Param

    ALL = [
      # Details of an app in the store. When the app is unavailable, `response.success`
      # is false and `response.data` is nil.
      # @see https://wiki.teamfortress.com/wiki/User:RJackson/StorefrontAPI#appdetails
      Endpoint.new(
        :app_details, "appdetails/", api: :store, key: false, returns: Structs::AppDetails::Details,
        params: {
          appid: param.integer(as: :appids),
          # e.g. ["basic", "price_overview"]; every field when empty
          filters: param.string_list(default: []),
          # Country code for the prices
          country_code: param.string(as: :cc, default: "US"),
          # Language of the texts
          locale: param.string(as: :l, default: "en")
        }
      ),

      # Global achievement unlock percentages of an app
      # @see https://developer.valvesoftware.com/wiki/Steam_Web_API#GetGlobalAchievementPercentagesForApp_.28v0002.29
      Endpoint.new(
        :app_global_achievements, "ISteamUserStats/GetGlobalAchievementPercentagesForApp/v0002/",
        key: false, returns: Structs::AppGlobalAchievements,
        params: {appid: param.integer(as: :gameid)}
      ),

      # Latest news of an app
      # @see https://developer.valvesoftware.com/wiki/Steam_Web_API#GetNewsForApp_.28v0002.29
      Endpoint.new(
        :app_news, "ISteamNews/GetNewsForApp/v0002/", key: false, returns: Structs::AppNews,
        params: {
          appid: param.integer,
          # Number of news items
          count: param.integer,
          # Maximum length of each item's contents
          maxlength: param.integer(default: 300)
        }
      ),

      # Number of players currently in a game
      # @see https://wiki.teamfortress.com/wiki/WebAPI/GetNumberOfCurrentPlayers
      Endpoint.new(
        :game_current_players, "ISteamUserStats/GetNumberOfCurrentPlayers/v0001/",
        key: false, returns: Structs::GameCurrentPlayers,
        params: {appid: param.integer}
      ),

      # A player's achievements in an app
      # @see https://developer.valvesoftware.com/wiki/Steam_Web_API#GetPlayerAchievements_.28v0001.29
      Endpoint.new(
        :player_achievements, "ISteamUserStats/GetPlayerAchievements/v0001/", returns: Structs::PlayerAchievements,
        params: {appid: param.integer, steamid: param.integer}
      ),

      # A player's friend list, if public
      # @see https://developer.valvesoftware.com/wiki/Steam_Web_API#GetFriendList_.28v0001.29
      Endpoint.new(
        :player_friends, "ISteamUser/GetFriendList/v0001/", returns: Structs::PlayerFriends,
        params: {steamid: param.integer, relationship: param.string(default: "all", in: %w[all friend])}
      ),

      # A player's stats and achievements in a game
      # @see https://developer.valvesoftware.com/wiki/Steam_Web_API#GetUserStatsForGame_.28v0002.29
      Endpoint.new(
        :player_game_stats, "ISteamUserStats/GetUserStatsForGame/v0002/", returns: Structs::PlayerGameStats,
        params: {appid: param.integer, steamid: param.integer}
      ),

      # A player's Steam level
      # @see https://wiki.teamfortress.com/wiki/WebAPI/GetSteamLevel
      Endpoint.new(
        :player_level, "IPlayerService/GetSteamLevel/v0001/", returns: Structs::PlayerLevel,
        params: {steamid: param.integer}
      ),

      # The games a player owns, if public
      # @see https://developer.valvesoftware.com/wiki/Steam_Web_API#GetOwnedGames_.28v0001.29
      Endpoint.new(
        :player_owned_games, "IPlayerService/GetOwnedGames/v0001/", returns: Structs::PlayerOwnedGames,
        params: {
          steamid: param.integer,
          # Include each game's name and icon
          include_appinfo: param.boolean(default: false),
          # Include free games the player has played
          include_played_free_games: param.boolean(default: false)
        }
      ),

      # The games a player played in the last two weeks
      # @see https://developer.valvesoftware.com/wiki/Steam_Web_API#GetRecentlyPlayedGames_.28v0001.29
      Endpoint.new(
        :player_recent_games, "IPlayerService/GetRecentlyPlayedGames/v0001/", returns: Structs::PlayerRecentGames,
        params: {steamid: param.integer, count: param.integer(default: 5)}
      ),

      # The 64 bit Steam ID a vanity URL (steamcommunity.com/id/<vanityurl>) resolves to
      # @see https://wiki.teamfortress.com/wiki/WebAPI/ResolveVanityURL
      Endpoint.new(
        :player_steamid, "ISteamUser/ResolveVanityURL/v0001/", returns: Structs::PlayerSteamId,
        params: {vanityurl: param.string}
      ),

      # Profile summaries of up to 100 players
      # @see https://developer.valvesoftware.com/wiki/Steam_Web_API#GetPlayerSummaries_.28v0002.29
      Endpoint.new(
        :player_summaries, "ISteamUser/GetPlayerSummaries/v0002/", returns: Structs::PlayerSummaries,
        params: {steamids: param.integer_list}
      )
    ].to_h { |endpoint| [endpoint.name, endpoint] }.freeze
  end
end
