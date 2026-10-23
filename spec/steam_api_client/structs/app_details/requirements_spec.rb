require "spec_helper"

RSpec.describe SteamApiClient::Structs::AppDetails::Requirements do
  subject { described_class.new(params) }

  describe "#initialize" do
    let(:params) do
      {
        minimum: minimum,
        recommended: recommended
      }
    end

    context "when the params are present" do
      let(:minimum) { "Minimum: OS, RAM" }
      let(:recommended) { "Recommended: OS, RAM, HD" }

      it { is_expected.to have_attributes(**params) }
    end

    context "when the params are missing" do
      let(:params) { {} }

      it { is_expected.to have_attributes(minimum: nil, recommended: nil) }
    end
  end
end
