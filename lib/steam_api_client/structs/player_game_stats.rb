module SteamApiClient
  module Structs
    # Struct that holds all Player Stats for a given game/appid
    # @see https://developer.valvesoftware.com/wiki/Steam_Web_API#GetUserStatsForGame_.28v0002.29
    class PlayerGameStats < Base
      class InternalPlayerGameStatsAttributes < Dry::Struct
        attribute :name?, Types::String
        attribute :achieved?, Types::Integer
      end

      attribute :playerstats do
        attribute :steamID?, Types::Coercible::Integer.optional.default(nil)
        attribute :gameName?, Types::String
        attribute :achievements?, Types::Strict::Array.of(
          InternalPlayerGameStatsAttributes
        )
      end
    end
  end
end
