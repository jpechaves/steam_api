require "spec_helper"

# Real GetPlayerBans and GetBadges responses, anonymized and trimmed (see spec/fixtures/steam/README.md)
RSpec.describe "GetPlayerBans and GetBadges real responses" do
  describe "GetPlayerBans" do
    subject(:bans) { parse_steam_fixture("player_bans", :player_bans) }

    it "parses each player's ban status" do
      expect(bans).to all(be_a(SteamApiClient::PlayerBan))
      expect(bans.first).to eq(SteamApiClient::PlayerBan.new(
        steam_id: 76561197960435530, community_banned: false, vac_banned: false, number_of_vac_bans: 0,
        days_since_last_ban: 0, number_of_game_bans: 0, economy_ban: "none"
      ))
    end

    it "parses VAC, game and community bans" do
      expect(bans[1]).to have_attributes(steam_id: 76561198000000001, vac_banned: true, number_of_vac_bans: 1, days_since_last_ban: 2032)
      expect(bans[2]).to have_attributes(community_banned: true, vac_banned: false, number_of_game_bans: 1, days_since_last_ban: 2695)
    end
  end

  describe "GetBadges" do
    subject(:result) { parse_steam_fixture("player_badges", :player_badges) }

    it "parses the level progress" do
      expect(result).to be_a(SteamApiClient::PlayerBadges).and(have_attributes(
        player_level: 157, player_xp: 131270, player_xp_needed_current_level: 131200, player_xp_needed_to_level_up: 1530
      ))
    end

    it "parses community and game badges" do
      community, game = result.badges

      expect(community).to eq(SteamApiClient::PlayerBadges::Badge.new(
        badge_id: 13, level: 1280, completion_time: 1787785402, xp: 1530, scarcity: 251922,
        app_id: nil, community_item_id: nil, border_color: nil
      ))
      expect(game).to have_attributes(badge_id: 1, app_id: 440, community_item_id: 1000000000000000001, border_color: 0)
    end

    it "returns nil for a private profile" do
      expect(parse_steam_fixture("player_badges_private", :player_badges)).to be_nil
    end
  end
end
