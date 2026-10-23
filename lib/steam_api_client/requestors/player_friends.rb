module SteamApiClient
  module Requestors
    # Class that expose the necessary method(s) to get an User
    # friend list in the Steam Web Api.
    class PlayerFriends < Base
      # Get an User complete friend list, if public.
      # @param [Integer] steamid The Steam user id
      # @param [String] relationship Relationship filter. Possibles values: 'all', 'friend'.
      # @return [SteamApiClient::Structs::PlayerFriends] instance with the
      #   player friends list.
      def retrieve(steamid, relationship = "all")
        build_request_and_run(
          SteamApiClient::Structs::Requests::GetPlayerFriends,
          SteamApiClient::Structs::PlayerFriends,
          steamid: steamid,
          relationship: relationship
        )
      end
    end
  end
end
