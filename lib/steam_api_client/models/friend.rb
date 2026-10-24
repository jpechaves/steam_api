module SteamApiClient
  # A friend in a player's friend list, from `player_friends`
  # @see https://developer.valvesoftware.com/wiki/Steam_Web_API#GetFriendList_.28v0001.29
  Friend = Model.define(
    steam_id: [:integer, from: :steamid],
    # "friend"
    relationship: :string,
    # When they became friends, in unix time
    friend_since: [:integer, optional: true]
  )
end
