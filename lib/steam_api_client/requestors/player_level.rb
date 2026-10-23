module SteamApiClient
  module Requestors
    # Class that exposes the necessary method(s) to get level of an user.
    class PlayerLevel < Base
      # Returns the user current level on Steam.
      # @param [Integer] steamid The Steam user id
      # @return [SteamApiClient::Structs::PlayerLevel] instance with the
      #   player level.
      def retrieve(steamid:)
        build_request_and_run(
          SteamApiClient::Structs::Requests::GetPlayerLevel,
          SteamApiClient::Structs::PlayerLevel,
          steamid: steamid
        )
      end
    end
  end
end
