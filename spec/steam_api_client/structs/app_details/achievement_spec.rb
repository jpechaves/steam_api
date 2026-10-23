require "spec_helper"

RSpec.describe SteamApiClient::Structs::AppDetails::Achievement do
  subject { described_class.new(params) }

  describe "#initialize" do
    let(:params) { {name: name, path: path} }

    context "when the params are present" do
      let(:name) { "The Fool" }
      let(:path) { "https://cdn.akamai.steamstatic.com/steamcommunity/public/images/apps/1091500/7975d6e5d790b88f030195e3b1a38e49a5de1c8d.jpg" }

      it { is_expected.to have_attributes(**params) }
    end

    context "when the params are nil" do
      let(:name) { nil }
      let(:path) { nil }

      it { is_expected.to have_attributes(**params) }
    end

    context "when the params are missing" do
      let(:params) { {} }

      it "raises a Dry::Struct::Error" do
        expect { subject }.to raise_error(Dry::Struct::Error)
      end
    end
  end
end
