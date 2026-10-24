module SteamApiClient
  # The share of players who unlocked an achievement, from `app_global_achievements`
  # @see https://developer.valvesoftware.com/wiki/Steam_Web_API#GetGlobalAchievementPercentagesForApp_.28v0002.29
  GlobalAchievement = Model.define(
    # The achievement's API name
    name: :string,
    # Percentage of players, e.g. 49.6
    percent: :float
  )
end
