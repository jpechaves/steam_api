require "spec_helper"

# Every request struct validates its required params before building
RSpec.describe "Request structs .build_from_params" do
  # Params the struct needs but build_from_params doesn't check (the requestor always passes them)
  unchecked = {SteamApiClient::Structs::Requests::GetAppDetails => %i[filters cc l]}

  {
    SteamApiClient::Structs::Requests::GetAppDetails => {appid: 570, filters: [], cc: "US", l: "en"},
    SteamApiClient::Structs::Requests::GetAppGlobalAchievements => {gameid: 440},
    SteamApiClient::Structs::Requests::GetAppNews => {appid: 440, count: 2, maxlength: 300},
    SteamApiClient::Structs::Requests::GetGameCurrentPlayers => {appid: 440},
    SteamApiClient::Structs::Requests::GetPlayerAchievements => {appid: 440, steamid: 1},
    SteamApiClient::Structs::Requests::GetPlayerFriends => {steamid: 1, relationship: "all"},
    SteamApiClient::Structs::Requests::GetPlayerGameStats => {appid: 440, steamid: 1},
    SteamApiClient::Structs::Requests::GetPlayerLevel => {steamid: 1},
    SteamApiClient::Structs::Requests::GetPlayerOwnedGames => {steamid: 1, include_appinfo: false, include_played_free_games: false},
    SteamApiClient::Structs::Requests::GetPlayerRecentGames => {steamid: 1, count: 5},
    SteamApiClient::Structs::Requests::GetPlayerSteamId => {vanityurl: "gabelogannewell"},
    SteamApiClient::Structs::Requests::GetPlayerSummaries => {steamids: [1]}
  }.each do |struct, params|
    describe struct do
      it "builds the struct from complete params" do
        expect(struct.build_from_params(params)).to have_attributes(params)
      end

      (params.keys - unchecked.fetch(struct, [])).each do |key|
        it "raises when :#{key} is missing" do
          expect { struct.build_from_params(params.except(key)) }.to raise_error(ArgumentError, /#{key}.* missing/)
        end
      end
    end
  end

  describe SteamApiClient::Structs::Requests::GetPlayerFriends do
    it "only allows the all and friend relationships" do
      expect { described_class.build_from_params(steamid: 1, relationship: "enemy") }.to raise_error(ArgumentError, /relationship value not allowed/)
    end
  end
end
