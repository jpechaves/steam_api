module SteamApiClient
  # Built first, then named under PlayerGameStats below
  stat = Model.define(
    # A game-defined stat, e.g. "Scout.accum.iDamageDealt"
    name: :string,
    # Integer or Float, as Steam sends it
    value: :number
  )
  achievement = Model.define(
    # The achievement's API name, e.g. "TF_PLAY_GAME_EVERYCLASS"
    name: :string,
    achieved: :boolean
  )

  # A player's stats and unlocked achievements in a game, from `player_game_stats`
  # @see https://developer.valvesoftware.com/wiki/Steam_Web_API#GetUserStatsForGame_.28v0002.29
  PlayerGameStats = Model.define(
    steam_id: [:integer, from: :steamID, optional: true],
    game_name: [:string, from: :gameName, optional: true],
    stats: [[stat], default: []],
    achievements: [[achievement], default: []]
  )
  PlayerGameStats.const_set(:Stat, stat)
  PlayerGameStats.const_set(:Achievement, achievement)
end
