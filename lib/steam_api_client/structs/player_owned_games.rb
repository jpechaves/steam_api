module SteamApiClient
  module Structs
    # Struct that holds all user owned games
    # @see https://developer.valvesoftware.com/wiki/Steam_Web_API#GetOwnedGames_.28v0001.29
    class PlayerOwnedGames < Base
      class InternalPlayerOwnedGames < Base
        attribute :appid, Types::Integer
        attribute :name?, Types::String
        attribute :playtime_forever, Types::Integer
        attribute :img_icon_url?, Types::String
        attribute :playtime_windows_forever, Types::Integer
        attribute :playtime_mac_forever, Types::Integer
        attribute :playtime_linux_forever, Types::Integer
        attribute :rtime_last_played, Types::Integer
      end

      attribute :response do
        attribute :game_count?, Types::Integer
        attribute :games?, Types::Strict::Array.of(
          InternalPlayerOwnedGames
        )
      end
    end
  end
end
