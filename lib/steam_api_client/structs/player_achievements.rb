module SteamApiClient
  module Structs
    # Struct that holds all Player Achievements of an app information
    # @see https://developer.valvesoftware.com/wiki/Steam_Web_API#GetPlayerAchievements_.28v0001.29
    class PlayerAchievements < Base
      class InternalPlayerAchievementsAttributes < Base
        attribute :apiname?, Types::String
        attribute :achieved?, Types::Integer
        attribute :unlocktime?, Types::Integer
      end

      attribute :playerstats do
        attribute :steamID?, Types::Coercible::Integer.optional.default(nil)
        attribute :error?, Types::String
        attribute :gameName?, Types::String
        attribute :achievements?, Types::Strict::Array.of(
          InternalPlayerAchievementsAttributes
        )
        attribute :success, Types::Bool
      end
    end
  end
end
