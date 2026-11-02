require "spec_helper"

# Real GetSchemaForGame responses, trimmed (see spec/fixtures/steam/README.md)
RSpec.describe "GetSchemaForGame real responses" do
  it "parses the achievements and stats" do
    schema = parse_steam_fixture("app_schema", :app_schema)

    expect(schema).to be_a(SteamApiClient::AppSchema).and(have_attributes(game_name: "Portal 2", game_version: "1108170007"))
    expect(schema.achievements.first).to be_a(SteamApiClient::AppSchema::Achievement).and(have_attributes(
      name: "ACH.SURVIVE_CONTAINER_RIDE", display_name: "Wake Up Call", description: "Survive the manual override", hidden: false,
      icon: end_with(".jpg"), icon_gray: end_with(".jpg"), default_value: 0
    ))
    expect(schema.stats.first).to eq(SteamApiClient::AppSchema::Stat.new(name: "PS3.SP.progress", display_name: nil, default_value: 0))
  end

  it "reads a hidden achievement's missing description as nil, and missing stats as []" do
    schema = parse_steam_fixture("app_schema_hidden", :app_schema)

    expect(schema.achievements.last).to have_attributes(name: "TheFool", hidden: true, description: nil)
    expect(schema.stats).to eq([])
  end

  it "returns nil for an app without stats or achievements" do
    expect(parse_steam_fixture("app_schema_no_stats", :app_schema)).to be_nil
  end

  it "raises HttpBadRequest for an unknown app" do
    expect { parse_steam_fixture("app_schema_unknown", :app_schema, status: 400) }.to raise_error(SteamApiClient::Errors::HttpBadRequest)
  end
end
