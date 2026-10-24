module SteamApiClient
  # A game in a player's library, from `player_owned_games` and `player_recent_games`.
  # Playtimes are in minutes.
  # @see https://developer.valvesoftware.com/wiki/Steam_Web_API#GetOwnedGames_.28v0001.29
  Game = Model.define(
    app_id: [:integer, from: :appid],
    # Name and icon: only with include_appinfo: true (always sent for recent games)
    name: [:string, optional: true],
    img_icon_url: [:string, optional: true],
    playtime_forever: :integer,
    # Only sent when played in the last two weeks
    playtime_2weeks: [:integer, optional: true],
    has_community_visible_stats: [:boolean, optional: true],
    has_leaderboards: [:boolean, optional: true],
    content_descriptor_ids: [[:integer], from: :content_descriptorids, optional: true],
    # Steam doesn't send these for most libraries anymore
    playtime_windows_forever: [:integer, optional: true],
    playtime_mac_forever: [:integer, optional: true],
    playtime_linux_forever: [:integer, optional: true],
    # Last time played, in unix time
    rtime_last_played: [:integer, optional: true]
  )

  # A player's library, from `player_owned_games`
  OwnedGames = Model.define(
    game_count: [:integer, optional: true],
    games: [[Game], default: []]
  )

  # The games a player played in the last two weeks, from `player_recent_games`
  RecentGames = Model.define(
    total_count: [:integer, optional: true],
    games: [[Game], default: []]
  )
end
