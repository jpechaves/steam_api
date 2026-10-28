require "spec_helper"

# Real Storefront responses (featured, featuredcategories), trimmed
# (see spec/fixtures/steam/README.md)
RSpec.describe "Storefront featured real responses" do
  describe "featured" do
    subject(:featured) { parse_steam_fixture("featured", :featured) }

    it "parses the lists per platform" do
      expect(featured).to be_a(SteamApiClient::Featured).and(have_attributes(large_capsules: [], layout: "defcon1"))
      expect(featured.featured_win.size).to eq(2)
      expect(featured.featured_mac + featured.featured_linux).to all(be_a(SteamApiClient::FeaturedItem))
    end

    it "parses a discounted app" do
      expect(featured.featured_win.first).to have_attributes(
        id: 3447280, type: 0, name: "Fantasy World Manager", discounted: true, discount_percent: 10,
        original_price: 1499, final_price: 1349, currency: "USD", discount_expiration: 1794416432,
        windows_available: true, mac_available: false, streaming_video_available: false, controller_support: nil,
        header_image: start_with("https://")
      )
    end

    it "has no discount expiration for an app at full price" do
      expect(featured.featured_win.last).to have_attributes(
        id: 2124120, discounted: false, original_price: 2999, final_price: 2999, discount_expiration: nil, controller_support: "full"
      )
    end
  end

  describe "featuredcategories" do
    subject(:categories) { parse_steam_fixture("featured_categories", :featured_categories) }

    it "parses the named lists, and leaves the others to retrieve_raw" do
      expect(categories).to be_a(SteamApiClient::FeaturedCategories)
      expect(categories.to_h.keys).to eq(%i[specials coming_soon top_sellers new_releases])
      expect(categories.specials).to be_a(SteamApiClient::FeaturedCategories::Category).and(have_attributes(
        id: "cat_specials", name: "Specials", items: [have_attributes(id: 4348910, discounted: true)]
      ))
      expect([categories.coming_soon, categories.top_sellers]).to all(have_attributes(items: all(be_a(SteamApiClient::FeaturedItem))))
    end

    it "reads a free app's original price as nil" do
      free, paid = categories.new_releases.items

      expect(free).to have_attributes(original_price: nil, final_price: 0)
      expect(paid).to have_attributes(original_price: 399, final_price: 399)
    end
  end
end
