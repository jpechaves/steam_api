require "spec_helper"

RSpec.describe SteamApiClient::Structs::Requests::GetPlayerAchievements do
  subject { described_class.new(params) }

  describe "#initialize" do
    let(:params) { {steamid: "123456789", appid: 12345} }

    it "initializes with the given steamid and appid" do
      expect(subject).to have_attributes(steamid: 123456789, appid: 12345)
    end

    context "when parameters are missing" do
      let(:params) { {} }

      it "raises an error" do
        expect { subject }.to raise_error(Dry::Struct::Error)
      end
    end
  end
end
