require "spec_helper"

RSpec.describe SteamApiClient::Structs::Requests::GetPlayerSteamId do
  subject { described_class.new(params) }

  describe "#initialize" do
    let(:params) { {vanityurl: "example"} }

    it "initializes with the given vanityurl" do
      expect(subject).to have_attributes(vanityurl: "example")
    end

    context "when vanityurl is missing" do
      let(:params) { {} }

      it "raises an error" do
        expect { subject }.to raise_error(Dry::Struct::Error)
      end
    end
  end
end
