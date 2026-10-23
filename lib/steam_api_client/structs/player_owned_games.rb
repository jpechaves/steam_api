module SteamApiClient
  module Structs
    # Struct that holds all user owned games
    # @see https://developer.valvesoftware.com/wiki/Steam_Web_API#GetOwnedGames_.28v0001.29
    class PlayerOwnedGames < Base
      class InternalPlayerOwnedGames < Base
        attribute :appid, Types::Integer
        attribute :name?, Types::String
        # Minutes played, in total and in the last two weeks (only sent when played recently)
        attribute :playtime_forever, Types::Integer
        attribute? :playtime_2weeks, Types::Integer
        attribute :img_icon_url?, Types::String
        attribute? :has_community_visible_stats, Types::Bool
        attribute? :has_leaderboards, Types::Bool
        attribute? :content_descriptorids, Types::Array.of(Types::Integer)
        # Steam doesn't send these for most libraries anymore
        attribute? :playtime_windows_forever, Types::Integer
        attribute? :playtime_mac_forever, Types::Integer
        attribute? :playtime_linux_forever, Types::Integer
        attribute? :rtime_last_played, Types::Integer
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
