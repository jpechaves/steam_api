require "spec_helper"

RSpec.describe SteamApiClient::Structs::Requests::GetGameCurrentPlayers do
  subject { described_class.new(params) }

  describe "#initialize" do
    let(:params) { {appid: 12345} }

    it "initializes with the given appid" do
      expect(subject).to have_attributes(appid: 12345)
    end

    context "when appid is missing" do
      let(:params) { {} }

      it "raises an error" do
        expect { subject }.to raise_error(Dry::Struct::Error)
      end
    end
  end
end
