module SteamApiClient
  # An app on a player's wishlist, from `player_wishlist`
  # @see https://steamapi.xpaw.me/#IWishlistService/GetWishlist
  WishlistItem = Model.define(
    app_id: [:integer, from: :appid],
    # The player's ranking of the app in their wishlist
    priority: :integer,
    # In unix time
    date_added: :integer
  )
end
