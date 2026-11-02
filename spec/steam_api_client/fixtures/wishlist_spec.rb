require "spec_helper"

# Real responses of the keyless wishlist and followed games endpoints, trimmed
# (see spec/fixtures/steam/README.md). Steam answers an empty object for a
# private profile, and for an empty wishlist.
RSpec.describe "Wishlist and followed games, real responses" do
  describe "GetWishlist" do
    it "parses the wishlist items" do
      items = parse_steam_fixture("player_wishlist", :player_wishlist)

      expect(items).to all(be_a(SteamApiClient::WishlistItem))
      expect(items.first).to eq(SteamApiClient::WishlistItem.new(app_id: 202350, priority: 3, date_added: 1403384867))
      expect(items.map(&:priority)).to include(0)
    end

    it "returns [] for a private or empty wishlist" do
      expect(parse_steam_fixture("player_wishlist_private", :player_wishlist)).to eq([])
    end
  end

  describe "GetWishlistItemCount" do
    it "returns the count" do
      expect(parse_steam_fixture("player_wishlist_count", :player_wishlist_count)).to eq(19)
    end

    it "returns nil for a private or empty wishlist" do
      expect(parse_steam_fixture("player_wishlist_private", :player_wishlist_count)).to be_nil
    end
  end

  describe "GetGamesFollowed" do
    it "returns the app IDs" do
      expect(parse_steam_fixture("player_followed_games", :player_followed_games)).to eq([400, 440, 620, 753, 17710])
    end

    it "returns [] for a private profile" do
      expect(parse_steam_fixture("player_wishlist_private", :player_followed_games)).to eq([])
    end
  end
end
