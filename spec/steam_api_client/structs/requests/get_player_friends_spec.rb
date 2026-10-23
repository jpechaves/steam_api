require "spec_helper"

RSpec.describe SteamApiClient::Structs::Requests::GetPlayerFriends do
  subject { described_class.new(params) }

  describe "#initialize" do
    let(:params) { {steamid: "123456789", relationship: "friend"} }

    it "initializes with the given steamid and relationship" do
      expect(subject).to have_attributes(steamid: "123456789", relationship: "friend")
    end

    context "when relationship is missing" do
      let(:params) { {steamid: "123456789"} }

      it "raises an error" do
        expect { subject }.to raise_error(Dry::Struct::Error)
      end
    end

    context "when steamid is missing" do
      let(:params) { {} }

      it "raises an error" do
        expect { subject }.to raise_error(Dry::Struct::Error)
      end
    end
  end
end
