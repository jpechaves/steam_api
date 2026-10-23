module SteamApiClient
  module Structs
    # Struct that holds information of all friends the player has
    # @see https://developer.valvesoftware.com/wiki/Steam_Web_API#GetFriendList_.28v0001.29
    class InternalPlayerFriends < Base
      attribute :steamid?, Types::Integer
      attribute :relationship?, Types::String
      attribute :friend_since, Types::Integer
    end

    class PlayerFriends < Base
      attribute :friendslist do
        attribute :friends?, Types::Strict::Array.of(InternalPlayerFriends)
      end
    end
  end
end
