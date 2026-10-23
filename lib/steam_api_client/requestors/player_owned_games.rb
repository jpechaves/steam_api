module SteamApiClient
  module Requestors
    # Class that exposes the necessary method(s) to get a list of
    # the player owned games, if public.
    class PlayerOwnedGames < Base
      # Returns a list of all games owned by the user.
      # @param [Integer] steamid The Steam user id
      # @param [Boolean] include_appinfo Flag to include all game related information
      # @param [Boolean] include_played_free_games Flag to include free games
      # @return [SteamApiClient::Structs::PlayerOwnedGames] instance with the
      #   player owned games details.
      def retrieve(steamid, include_appinfo: false, include_played_free_games: false)
        build_request_and_run(
          SteamApiClient::Structs::Requests::GetPlayerOwnedGames,
          SteamApiClient::Structs::PlayerOwnedGames,
          steamid: steamid,
          include_appinfo: include_appinfo,
          include_played_free_games: include_played_free_games
        )
      end
    end
  end
end
