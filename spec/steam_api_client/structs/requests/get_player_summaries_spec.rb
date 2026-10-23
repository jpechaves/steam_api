require "spec_helper"

RSpec.describe SteamApiClient::Structs::Requests::GetPlayerSummaries do
  subject { described_class.new(params) }

  describe "#initialize" do
    let(:params) { {steamids: [123456789, 987654321]} }

    it "initializes with the given steamids" do
      expect(subject).to have_attributes(steamids: [123456789, 987654321])
    end

    context "when steamids are missing" do
      let(:params) { {} }

      it "raises an error" do
        expect { subject }.to raise_error(Dry::Struct::Error)
      end
    end
  end
end
