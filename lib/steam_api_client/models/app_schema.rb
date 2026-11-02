module SteamApiClient
  # Built first, then named under AppSchema below
  achievement = Model.define(
    # The API name, as in `player_achievements` and `app_global_achievements`
    name: :string,
    # In the requested language
    display_name: [:string, from: :displayName],
    # nil for most hidden achievements
    description: [:string, optional: true],
    # Hidden until unlocked
    hidden: :boolean,
    # Icon URLs, unlocked and locked
    icon: [:string, optional: true],
    icon_gray: [:string, from: :icongray, optional: true],
    default_value: [:integer, from: :defaultvalue, optional: true]
  )
  stat = Model.define(
    # A game-defined stat, as in `player_game_stats`
    name: :string,
    # Often the same as the name, or ""
    display_name: [:string, from: :displayName, optional: true],
    # Integer or Float, as Steam sends it
    default_value: [:number, from: :defaultvalue, optional: true]
  )

  # The achievements and stats an app defines, from `app_schema`
  # @see https://developer.valvesoftware.com/wiki/Steam_Web_API#GetSchemaForGame_.28v2.29
  AppSchema = Model.define(
    # Often "" or an internal name like "ValveTestApp260"
    game_name: [:string, from: :gameName, optional: true],
    game_version: [:string, from: :gameVersion, optional: true],
    achievements: [[achievement], from: %i[availableGameStats achievements], default: []],
    stats: [[stat], from: %i[availableGameStats stats], default: []]
  )
  AppSchema.const_set(:Achievement, achievement)
  AppSchema.const_set(:Stat, stat)
end
