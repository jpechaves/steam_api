module SteamApiClient
  module Structs
    # Struct that holds all Player Stats for a given game/appid
    # @see https://developer.valvesoftware.com/wiki/Steam_Web_API#GetUserStatsForGame_.28v0002.29
    class PlayerGameStats < Base
      class InternalPlayerGameStatsAttributes < Base
        attribute :name?, Types::String
        attribute :achieved?, Types::Integer
      end

      # A game-defined stat, e.g. "Scout.accum.iDamageDealt" => 26580
      class Stat < Base
        attribute :name, Types::String
        # Integer or Float exactly as Steam sends it (coercing would truncate float stats)
        attribute :value, (Types::Strict::Integer | Types::Strict::Float).optional
      end

      attribute :playerstats do
        attribute :steamID?, Types::Coercible::Integer.optional.default(nil)
        attribute :gameName?, Types::String
        attribute :stats?, Types::Strict::Array.of(Stat)
        attribute :achievements?, Types::Strict::Array.of(
          InternalPlayerGameStatsAttributes
        )
      end
    end
  end
end
