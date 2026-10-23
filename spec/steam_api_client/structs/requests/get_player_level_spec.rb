require "spec_helper"

RSpec.describe SteamApiClient::Structs::Requests::GetPlayerLevel do
  subject { described_class.new(params) }

  describe "#initialize" do
    let(:params) { {steamid: "123456789"} }

    it "initializes with the given steamid" do
      expect(subject).to have_attributes(steamid: 123456789)
    end

    context "when steamid is missing" do
      let(:params) { {} }

      it "raises an error" do
        expect { subject }.to raise_error(Dry::Struct::Error)
      end
    end
  end
end
