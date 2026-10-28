module SteamApiClient
  # Every endpoint the client exposes, as `client.<name>.retrieve(**params)`, and
  # what it returns (see SteamApiClient::Model for the models).
  #
  # Web API paths are "<interface>/<method>/<version>/" under https://api.steampowered.com.
  # Storefront paths (`api: :store`) are relative to https://store.steampowered.com/api/,
  # Steam's unofficial store API.
  #
  # To add an endpoint, declare it here, with its model when it returns one.
  module Endpoints
    param = Endpoint::Param

    ALL = [
      # Details of an app in the store => AppDetails, or nil when the app is unavailable
      # @see https://wiki.teamfortress.com/wiki/User:RJackson/StorefrontAPI#appdetails
      Endpoint.new(
        :app_details, "appdetails/", api: :store, key: false, returns: AppDetails, at: AppDetails.method(:unwrap),
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

      # An app's DLC => AppDlc, or nil when the app is unknown
      Endpoint.new(
        :app_dlc, "dlcforapp/", api: :store, key: false, returns: AppDlc, at: AppDlc.method(:unwrap),
        params: {
          appid: param.integer,
          country_code: param.string(as: :cc, default: "US"),
          locale: param.string(as: :l, default: "en")
        }
      ),

      # Global achievement unlock percentages of an app => [GlobalAchievement]
      # @see https://developer.valvesoftware.com/wiki/Steam_Web_API#GetGlobalAchievementPercentagesForApp_.28v0002.29
      Endpoint.new(
        :app_global_achievements, "ISteamUserStats/GetGlobalAchievementPercentagesForApp/v0002/",
        key: false, returns: [GlobalAchievement], at: %i[achievementpercentages achievements],
        params: {appid: param.integer(as: :gameid)}
      ),

      # Latest news of an app => [NewsItem]
      # @see https://developer.valvesoftware.com/wiki/Steam_Web_API#GetNewsForApp_.28v0002.29
      Endpoint.new(
        :app_news, "ISteamNews/GetNewsForApp/v0002/", key: false, returns: [NewsItem], at: %i[appnews newsitems],
        params: {
          appid: param.integer,
          # Number of news items
          count: param.integer,
          # Maximum length of each item's contents
          maxlength: param.integer(default: 300)
        }
      ),

      # The apps featured on the store's front page => Featured
      # @see https://wiki.teamfortress.com/wiki/User:RJackson/StorefrontAPI#featured
      Endpoint.new(
        :featured, "featured/", api: :store, key: false, returns: Featured,
        params: {
          country_code: param.string(as: :cc, default: "US"),
          locale: param.string(as: :l, default: "en")
        }
      ),

      # The store front page's specials, top sellers, new releases and upcoming apps => FeaturedCategories
      # @see https://wiki.teamfortress.com/wiki/User:RJackson/StorefrontAPI#featuredcategories
      Endpoint.new(
        :featured_categories, "featuredcategories/", api: :store, key: false, returns: FeaturedCategories,
        params: {
          country_code: param.string(as: :cc, default: "US"),
          locale: param.string(as: :l, default: "en")
        }
      ),

      # Number of players currently in a game => Integer
      # @see https://wiki.teamfortress.com/wiki/WebAPI/GetNumberOfCurrentPlayers
      Endpoint.new(
        :game_current_players, "ISteamUserStats/GetNumberOfCurrentPlayers/v0001/",
        key: false, returns: :integer, at: %i[response player_count],
        params: {appid: param.integer}
      ),

      # Details of a package (a bundle or a sub) in the store => PackageDetails, or nil when unavailable
      # @see https://wiki.teamfortress.com/wiki/User:RJackson/StorefrontAPI#packagedetails
      Endpoint.new(
        :package_details, "packagedetails/", api: :store, key: false, returns: PackageDetails,
        at: PackageDetails.method(:unwrap),
        params: {
          # Steam rejects several IDs at once
          packageid: param.integer(as: :packageids),
          country_code: param.string(as: :cc, default: "US"),
          locale: param.string(as: :l, default: "en")
        }
      ),

      # A player's achievements in an app => PlayerAchievements
      # @see https://developer.valvesoftware.com/wiki/Steam_Web_API#GetPlayerAchievements_.28v0001.29
      Endpoint.new(
        :player_achievements, "ISteamUserStats/GetPlayerAchievements/v0001/", returns: PlayerAchievements, at: %i[playerstats],
        params: {appid: param.integer, steamid: param.integer}
      ),

      # The apps a player follows in the store => [Integer] app IDs ([] when not public)
      # @see https://steamapi.xpaw.me/#IStoreService/GetGamesFollowed
      Endpoint.new(
        :player_followed_games, "IStoreService/GetGamesFollowed/v1/", key: false, returns: [:integer], at: %i[response appids],
        params: {steamid: param.integer}
      ),

      # A player's friend list, if public => [Friend]
      # @see https://developer.valvesoftware.com/wiki/Steam_Web_API#GetFriendList_.28v0001.29
      Endpoint.new(
        :player_friends, "ISteamUser/GetFriendList/v0001/", returns: [Friend], at: %i[friendslist friends],
        params: {steamid: param.integer, relationship: param.string(default: "all", in: %w[all friend])}
      ),

      # A player's stats and achievements in a game => PlayerGameStats
      # @see https://developer.valvesoftware.com/wiki/Steam_Web_API#GetUserStatsForGame_.28v0002.29
      Endpoint.new(
        :player_game_stats, "ISteamUserStats/GetUserStatsForGame/v0002/", returns: PlayerGameStats, at: %i[playerstats],
        params: {appid: param.integer, steamid: param.integer}
      ),

      # A player's Steam level => Integer, or nil when the profile isn't visible
      # @see https://wiki.teamfortress.com/wiki/WebAPI/GetSteamLevel
      Endpoint.new(
        :player_level, "IPlayerService/GetSteamLevel/v0001/", returns: :integer, at: %i[response player_level],
        params: {steamid: param.integer}
      ),

      # The games a player owns => OwnedGames, or nil when the library isn't public
      # @see https://developer.valvesoftware.com/wiki/Steam_Web_API#GetOwnedGames_.28v0001.29
      Endpoint.new(
        :player_owned_games, "IPlayerService/GetOwnedGames/v0001/", returns: OwnedGames, at: %i[response],
        params: {
          steamid: param.integer,
          # Include each game's name and icon
          include_appinfo: param.boolean(default: false),
          # Include free games the player has played
          include_played_free_games: param.boolean(default: false)
        }
      ),

      # The games a player played in the last two weeks => RecentGames, or nil when not public
      # @see https://developer.valvesoftware.com/wiki/Steam_Web_API#GetRecentlyPlayedGames_.28v0001.29
      Endpoint.new(
        :player_recent_games, "IPlayerService/GetRecentlyPlayedGames/v0001/", returns: RecentGames, at: %i[response],
        params: {steamid: param.integer, count: param.integer(default: 5)}
      ),

      # The 64 bit Steam ID a vanity URL (steamcommunity.com/id/<vanityurl>) resolves to
      # => Integer, or nil when nothing matches
      # @see https://wiki.teamfortress.com/wiki/WebAPI/ResolveVanityURL
      Endpoint.new(
        :player_steamid, "ISteamUser/ResolveVanityURL/v0001/", returns: :integer, at: %i[response steamid],
        params: {vanityurl: param.string}
      ),

      # Profile summaries of up to 100 players => [PlayerSummary] (unknown IDs are left out)
      # @see https://developer.valvesoftware.com/wiki/Steam_Web_API#GetPlayerSummaries_.28v0002.29
      Endpoint.new(
        :player_summaries, "ISteamUser/GetPlayerSummaries/v0002/", returns: [PlayerSummary], at: %i[response players],
        params: {steamids: param.integer_list}
      ),

      # A player's wishlist => [WishlistItem] ([] when empty or not public)
      # @see https://steamapi.xpaw.me/#IWishlistService/GetWishlist
      Endpoint.new(
        :player_wishlist, "IWishlistService/GetWishlist/v1/", key: false, returns: [WishlistItem], at: %i[response items],
        params: {steamid: param.integer}
      ),

      # The number of apps on a player's wishlist => Integer, or nil when empty or not public
      # @see https://steamapi.xpaw.me/#IWishlistService/GetWishlistItemCount
      Endpoint.new(
        :player_wishlist_count, "IWishlistService/GetWishlistItemCount/v1/", key: false, returns: :integer, at: %i[response count],
        params: {steamid: param.integer}
      ),

      # Apps in the store matching a search term => [StoreSearchResult] (at most 10)
      Endpoint.new(
        :store_search, "storesearch/", api: :store, key: false, returns: [StoreSearchResult],
        at: StoreSearchResult.method(:unwrap),
        params: {
          term: param.string,
          country_code: param.string(as: :cc, default: "US"),
          locale: param.string(as: :l, default: "en")
        }
      )
    ].to_h { |endpoint| [endpoint.name, endpoint] }.freeze
  end
end
