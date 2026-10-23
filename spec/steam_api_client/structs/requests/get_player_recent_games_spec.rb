require "spec_helper"

RSpec.describe SteamApiClient::Structs::Requests::GetPlayerRecentGames do
  subject { described_class.new(params) }

  describe "#initialize" do
    let(:params) { {steamid: "123456789", count: 10} }

    it "initializes with the given steamid and count" do
      expect(subject).to have_attributes(steamid: "123456789", count: 10)
    end

    context "when count is missing" do
      let(:params) { {steamid: "123456789"} }

      it "raises an error" do
        expect { subject }.to raise_error(Dry::Struct::Error)
      end
    end

    context "when steamid is missing" do
      let(:params) { {count: 10} }

      it "raises an error" do
        expect { subject }.to raise_error(Dry::Struct::Error)
      end
    end
  end
end
