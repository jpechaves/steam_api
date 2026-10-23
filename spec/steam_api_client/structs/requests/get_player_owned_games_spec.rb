require "spec_helper"

RSpec.describe SteamApiClient::Structs::Requests::GetPlayerOwnedGames do
  subject { described_class.new(params) }

  describe "#initialize" do
    let(:params) { {steamid: "123456789", include_appinfo: true, include_played_free_games: false} }

    it "initializes with the given steamid and additional parameters" do
      expect(subject).to have_attributes(steamid: "123456789", include_appinfo: true, include_played_free_games: false)
    end

    context "when steamid is missing" do
      let(:params) { {} }

      it "raises an error" do
        expect { subject }.to raise_error(Dry::Struct::Error)
      end
    end

    context "when include_appinfo is missing" do
      let(:params) { {steamid: "123456789"} }

      it "raises an error" do
        expect { subject }.to raise_error(Dry::Struct::Error)
      end
    end
  end
end
