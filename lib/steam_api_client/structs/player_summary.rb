module SteamApiClient
  module Structs
    # Struct that holds the Player Summary information
    # @see https://developer.valvesoftware.com/wiki/Steam_Web_API#GetPlayerSummaries_.28v0002.29
    class PlayerSummary < Dry::Struct
      # 64bit SteamID of the user
      attribute :steamid, Types::String
      # The player's persona name (display name)
      attribute :personaname, Types::String
      # The full URL of the player's Steam Community profile.
      attribute :profileurl, Types::String
      # The full URL of the player's 32x32px avatar. If the user hasn't configured an avatar
      # this will be the default ? avatar.
      attribute :avatar, Types::String
      # The full URL of the player's 64x64px avatar. If the user hasn't configured an avatar
      # this will be the default ? avatar.
      attribute :avatarmedium, Types::String
      # The full URL of the player's 184x184px avatar. If the user hasn't configured an avatar
      # this will be the default ? avatar.
      attribute :avatarfull, Types::String
      # The user's current status. 0 - Offline, 1 - Online, 2 - Busy, 3 - Away, 4 - Snooze, 5 - looking to trade
      # 6 - looking to play. If the player's profile is private, this will always be "0".
      attribute :personastate, Types::Integer
      # This represents whether the profile is visible or not, and if it is visible, why you are allowed to see it.
      attribute :communityvisibilitystate, Types::Integer
      # If set, indicates the user has a community profile configured (will be set to '1')
      attribute :profilestate, Types::String
      # The last time the user was online, in unix time.
      attribute :lastlogoff, Types::Optional::Integer
      # If set, indicates the profile allows public comments.
      attribute :commentpermission, Types::Optional::Integer
    end
  end
end
