module SteamApiClient
  # Built first, then named PlayerAchievements::Achievement below
  achievement = Model.define(
    # The achievement's API name, e.g. "TF_PLAY_GAME_EVERYCLASS"
    api_name: [:string, from: :apiname],
    achieved: :boolean,
    # When it was unlocked, in unix time (0 when locked, or unknown)
    unlock_time: [:integer, from: :unlocktime, optional: true]
  )

  # A player's achievements in a game, from `player_achievements`
  # @see https://developer.valvesoftware.com/wiki/Steam_Web_API#GetPlayerAchievements_.28v0001.29
  PlayerAchievements = Model.define(
    steam_id: [:integer, from: :steamID, optional: true],
    game_name: [:string, from: :gameName, optional: true],
    achievements: [[achievement], default: []]
  )
  PlayerAchievements.const_set(:Achievement, achievement)
end
