module SteamApiClient
  module Structs
    # Struct that holds all user recent played games
    # @see https://developer.valvesoftware.com/wiki/Steam_Web_API#GetRecentlyPlayedGames_.28v0001.29
    class PlayerRecentGames < Base
      class InternalPlayerRecentGames < Base
        attribute :appid, Types::Integer
        attribute :name, Types::String
        attribute :playtime_2weeks, Types::Integer
        attribute :playtime_forever, Types::Integer
        attribute :img_icon_url, Types::String
      end

      attribute :response do
        attribute :total_count?, Types::Integer
        attribute :games?, Types::Strict::Array.of(
          InternalPlayerRecentGames
        ).optional
      end
    end
  end
end
