module SteamApiClient
  # A player's ban status, from `player_bans`. Steam names these keys in PascalCase.
  # @see https://steamapi.xpaw.me/#ISteamUser/GetPlayerBans
  PlayerBan = Model.define(
    steam_id: [:integer, from: :SteamId],
    # Banned from the Steam Community
    community_banned: [:boolean, from: :CommunityBanned],
    vac_banned: [:boolean, from: :VACBanned],
    number_of_vac_bans: [:integer, from: :NumberOfVACBans],
    # Days since the last VAC or game ban (0 when never banned)
    days_since_last_ban: [:integer, from: :DaysSinceLastBan],
    # Bans set by game developers
    number_of_game_bans: [:integer, from: :NumberOfGameBans],
    # Trade ban status: "none", "probation" or "banned"
    economy_ban: [:string, from: :EconomyBan]
  )
end
