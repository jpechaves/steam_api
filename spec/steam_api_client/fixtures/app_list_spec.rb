require "spec_helper"

# Real IStoreService/GetAppList responses, trimmed (see spec/fixtures/steam/README.md)
RSpec.describe "GetAppList real responses" do
  it "parses a page and where the next one starts" do
    page = parse_steam_fixture("app_list", :app_list)

    expect(page).to be_a(SteamApiClient::AppList).and(have_attributes(have_more_results: true, last_app_id: 30))
    expect(page.apps.first).to eq(SteamApiClient::AppList::App.new(
      app_id: 10, name: "Counter-Strike", last_modified: 1745368572, price_change_number: 39636801
    ))
  end

  it "has no next page on the last one (Steam leaves have_more_results and last_appid out)" do
    page = parse_steam_fixture("app_list_last_page", :app_list)

    expect(page).to have_attributes(have_more_results: false, last_app_id: nil, apps: all(be_a(SteamApiClient::AppList::App)))
  end

  it "returns nil past the last page, or when nothing changed since if_modified_since" do
    expect(parse_steam_fixture("app_list_empty", :app_list)).to be_nil
  end
end
