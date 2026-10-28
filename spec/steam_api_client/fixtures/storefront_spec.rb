require "spec_helper"

# Real Storefront responses (packagedetails, dlcforapp, storesearch), trimmed
# (see spec/fixtures/steam/README.md)
RSpec.describe "Storefront real responses" do
  describe "packagedetails" do
    it "unwraps a package's data into PackageDetails" do
      package = parse_steam_fixture("package_details", :package_details)

      expect(package).to be_a(SteamApiClient::PackageDetails).and(have_attributes(
        package_id: 469, name: "The Orange Box", page_content: start_with("<p>"), purchase_text: nil,
        header_image: start_with("https://"), small_logo: start_with("https://")
      ))
      expect(package.apps).to include(SteamApiClient::PackageDetails::App.new(id: 440, name: "Team Fortress 2"))
      expect(package.price).to eq(SteamApiClient::PackageDetails::Price.new(currency: "USD", initial: 1999, final: 1999, discount_percent: 0, individual: 1998))
      expect(package.platforms).to eq(SteamApiClient::AppDetails::Platforms.new(windows: true, mac: false, linux: true))
      expect(package.controller).to eq(SteamApiClient::PackageDetails::Controller.new(full_gamepad: false))
      expect(package.release_date).to eq(SteamApiClient::AppDetails::ReleaseDate.new(coming_soon: false, date: ""))
    end

    it "has no price for a free package" do
      expect(parse_steam_fixture("package_details_free", :package_details)).to have_attributes(package_id: 197845, price: nil, header_image: nil)
    end

    it "returns nil for an unavailable package" do
      expect(parse_steam_fixture("package_details_unavailable", :package_details)).to be_nil
    end
  end

  describe "dlcforapp" do
    it "parses the app's DLC" do
      result = parse_steam_fixture("app_dlc", :app_dlc)

      expect(result).to be_a(SteamApiClient::AppDlc).and(have_attributes(app_id: 292030, name: start_with("The Witcher 3")))
      expect(result.dlc).to all(be_a(SteamApiClient::AppDlc::Dlc))
      expect(result.dlc.last).to have_attributes(
        id: 1229320, controller_support: "full", header_image: start_with("https://"),
        price_overview: SteamApiClient::AppDlc::Price.new(currency: "USD", initial: 1099, final: 1099, discount_percent: 0),
        release_date: SteamApiClient::AppDlc::ReleaseDates.new(steam: 1581374766, mac: 1581374752, linux: 1581374752)
      )
    end

    it "reads unpriced DLC and unknown release dates as nil" do
      dlc = parse_steam_fixture("app_dlc", :app_dlc).dlc.first

      expect(dlc).to have_attributes(price_overview: nil, release_date: have_attributes(steam: nil, mac: nil, linux: nil))
    end

    it "keeps the milliseconds Steam sometimes adds to release times, and reads a missing release date as nil" do
      no_date, with_millis = parse_steam_fixture("app_dlc_timestamps", :app_dlc).dlc

      expect(no_date).to have_attributes(release_date: nil, controller_support: nil)
      expect(with_millis.release_date).to have_attributes(steam: 1382631650.585, mac: 1382631725)
    end

    it "returns nil for an unknown app" do
      expect(parse_steam_fixture("app_dlc_unknown", :app_dlc)).to be_nil
    end
  end

  describe "storesearch" do
    subject(:results) { parse_steam_fixture("store_search", :store_search) }

    it "parses the results" do
      expect(results).to all(be_a(SteamApiClient::StoreSearchResult))
      expect(results.first).to have_attributes(
        id: 620, type: "app", name: "Portal 2", metascore: 95, streaming_video: false, controller_support: "full",
        price: SteamApiClient::StoreSearchResult::Price.new(currency: "USD", initial: 999, final: 999),
        platforms: SteamApiClient::AppDetails::Platforms.new(windows: true, mac: false, linux: true)
      )
    end

    it "reads a free app's missing price, and Steam's empty metascore, as nil" do
      expect(results[1]).to have_attributes(price: nil, metascore: nil)
      expect(results[2]).to have_attributes(price: have_attributes(final: 99), metascore: nil)
    end

    it "returns [] when nothing matches" do
      expect(parse_steam_fixture("store_search_no_results", :store_search)).to eq([])
    end

    it "returns [] when Steam leaves the items out" do
      expect(SteamApiClient::Endpoints::ALL[:store_search].result({})).to eq([])
    end
  end
end
