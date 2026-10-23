module SteamApiClient
  module Structs
    # Struct that holds all App Global Achievements information
    # @see https://developer.valvesoftware.com/wiki/Steam_Web_API#GetGlobalAchievementPercentagesForApp_.28v0002.29
    class AppGlobalAchievements < Base
      class InternalAppAchievementsAttributes < Dry::Struct
        attribute :name, Types::String
        attribute :percent, Types::Float
      end

      attribute :achievementpercentages do
        attribute :achievements?, Types::Strict::Array.of(
          InternalAppAchievementsAttributes
        )
      end
    end
  end
end
