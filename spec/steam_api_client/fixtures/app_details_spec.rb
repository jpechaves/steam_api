require "spec_helper"

# A real Storefront response (Team Fortress 2), trimmed (see spec/fixtures/steam/README.md)
RSpec.describe "appdetails real responses" do
  subject(:app) { parse_steam_fixture("app_details", :app_details) }

  it "unwraps the app's data into AppDetails" do
    expect(app).to be_a(SteamApiClient::AppDetails).and(have_attributes(
      app_id: 440, type: "game", name: "Team Fortress 2", is_free: true, required_age: 0,
      developers: ["Valve"], publishers: ["Valve"], website: "http://www.teamfortress.com/"
    ))
  end

  it "builds the nested parts" do
    expect(app.platforms).to eq(SteamApiClient::AppDetails::Platforms.new(windows: true, mac: false, linux: true))
    expect(app.pc_requirements).to be_a(SteamApiClient::AppDetails::Requirements).and(have_attributes(minimum: start_with("<strong>")))
    expect(app.metacritic).to have_attributes(score: 92, url: start_with("https://www.metacritic.com/"))
    expect(app.release_date).to have_attributes(coming_soon: false, date: "Oct 10, 2007")
    expect(app.support_info).to be_a(SteamApiClient::AppDetails::SupportInfo)
    expect(app.content_descriptors).to eq(SteamApiClient::AppDetails::ContentDescriptors.new(ids: [], notes: nil))
  end

  it "builds the lists, converting Steam's string IDs" do
    expect(app.genres.first).to eq(SteamApiClient::AppDetails::Genre.new(id: 1, description: "Action"))
    expect(app.categories).to all(be_a(SteamApiClient::AppDetails::Category))
    expect(app.screenshots.first).to have_attributes(id: 0, path_full: start_with("https://"))
    expect(app.movies.first).to be_a(SteamApiClient::AppDetails::Movie).and(have_attributes(hls_h264: include(".m3u8"), highlight: true))
    expect(app.package_groups.first.subs.first).to be_a(SteamApiClient::AppDetails::Package).and(have_attributes(package_id: 197845, is_free_license: true))
    expect(app.achievements).to have_attributes(total: 520, highlighted: all(be_a(SteamApiClient::AppDetails::HighlightedAchievement)))
  end

  it "unwraps the review count" do
    expect(app.recommendations).to eq(48123)
  end

  it "has no price for a free game" do
    expect(app.price_overview).to be_nil
  end

  it "reads the empty array Steam sends for missing requirements as nil" do
    json = JSON.parse(steam_fixture("app_details"), symbolize_names: true)
    json[:"440"][:data][:mac_requirements] = []

    expect(SteamApiClient::Endpoints::ALL[:app_details].result(json).mac_requirements).to be_nil
  end

  it "returns nil for an unavailable app" do
    expect(parse_steam_fixture("app_details_unavailable", :app_details)).to be_nil
  end

  it "converts to a plain Hash" do
    expect(app.to_h).to include(app_id: 440, platforms: {windows: true, mac: false, linux: true}, genres: include({id: 1, description: "Action"}))
  end
end
