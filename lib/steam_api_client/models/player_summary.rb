module SteamApiClient
  # A player's public profile, from `player_summaries`. The optional fields are
  # nil when the profile (or that part of it) isn't public.
  # @see https://developer.valvesoftware.com/wiki/Steam_Web_API#GetPlayerSummaries_.28v0002.29
  PlayerSummary = Model.define(
    # 64 bit SteamID
    steam_id: [:integer, from: :steamid],
    # Display name
    persona_name: [:string, from: :personaname],
    profile_url: [:string, from: :profileurl],
    # 32x32, 64x64 and 184x184 avatar URLs (Steam's "?" avatar when none is set)
    avatar: :string,
    avatar_medium: [:string, from: :avatarmedium],
    avatar_full: [:string, from: :avatarfull],
    # Hash used in the avatar URLs
    avatar_hash: [:string, from: :avatarhash, optional: true],
    # 0 offline, 1 online, 2 busy, 3 away, 4 snooze, 5 looking to trade, 6 looking to play.
    # Always 0 for private profiles.
    persona_state: [:integer, from: :personastate],
    persona_state_flags: [:integer, from: :personastateflags, optional: true],
    # 1 private (not visible to you), 3 public
    community_visibility_state: [:integer, from: :communityvisibilitystate],
    # 1 when the player has set up a community profile
    profile_state: [:integer, from: :profilestate, optional: true],
    # Last time online, in unix time
    last_logoff: [:integer, from: :lastlogoff, optional: true],
    # 1 when the profile allows public comments
    comment_permission: [:integer, from: :commentpermission, optional: true],
    real_name: [:string, from: :realname, optional: true],
    # Account creation, in unix time
    time_created: [:integer, from: :timecreated, optional: true],
    # ISO 3166 country code
    country_code: [:string, from: :loccountrycode, optional: true],
    # The player's primary group (a group SteamID)
    primary_clan_id: [:integer, from: :primaryclanid, optional: true]
  )
end
