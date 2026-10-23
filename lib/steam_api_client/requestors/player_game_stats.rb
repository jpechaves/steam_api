module SteamApiClient
  module Requestors
    # Class that exposes the necessary method(s) to get the stats of a
    # player for a given game/appid.
    class PlayerGameStats < Base
      # Returns a list of stats for a user for a given game/appid.
      # @param [Integer] appid The Steam app id
      # @param [Integer] steamid The Steam user id
      # @return [SteamApiClient::Structs::PlayerGameStats] instance with the
      #   player summary details.
      def retrieve(appid:, steamid:)
        build_request_and_run(
          SteamApiClient::Structs::Requests::GetPlayerGameStats,
          SteamApiClient::Structs::PlayerGameStats,
          appid: appid,
          steamid: steamid
        )
      end
    end
  end
end
