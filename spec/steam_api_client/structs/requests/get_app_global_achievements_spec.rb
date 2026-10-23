require "spec_helper"

RSpec.describe SteamApiClient::Structs::Requests::GetAppGlobalAchievements do
  subject { described_class.new(params) }

  describe "#initialize" do
    let(:params) { {gameid: 12345} }

    it "initializes with the given gameid" do
      expect(subject).to have_attributes(gameid: 12345)
    end

    context "when gameid is missing" do
      let(:params) { {} }

      it "raises an error" do
        expect { subject }.to raise_error(Dry::Struct::Error)
      end
    end
  end
end
