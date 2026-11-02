module SteamApiClient
  # Built first, then named PlayerBadges::Badge below
  badge = Model.define(
    badge_id: [:integer, from: :badgeid],
    level: :integer,
    # In unix time
    completion_time: :integer,
    xp: :integer,
    # How many players have this badge
    scarcity: :integer,
    # Only for game badges (trading cards)
    app_id: [:integer, from: :appid, optional: true],
    community_item_id: [:integer, from: :communityitemid, optional: true],
    # 1 for a foil badge
    border_color: [:integer, optional: true]
  )

  # A player's badges and Steam level progress, from `player_badges`
  # @see https://steamapi.xpaw.me/#IPlayerService/GetBadges
  PlayerBadges = Model.define(
    player_level: :integer,
    player_xp: :integer,
    # The XP where the current level starts, and what's left for the next one
    player_xp_needed_current_level: :integer,
    player_xp_needed_to_level_up: :integer,
    badges: [[badge], default: []]
  )
  PlayerBadges.const_set(:Badge, badge)
end
