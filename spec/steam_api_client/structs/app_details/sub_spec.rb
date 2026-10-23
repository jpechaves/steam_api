require "spec_helper"

RSpec.describe SteamApiClient::Structs::AppDetails::Sub do
  subject { described_class.new(params) }

  describe "#initialize" do
    let(:params) do
      {
        packageid: 12345,
        percent_savings_text: "50%",
        percent_savings: 50,
        option_text: "Buy Now",
        option_description: "Special offer",
        can_get_free_license: "No",
        is_free_license: false,
        price_in_cents_with_discount: 4999
      }
    end

    context "when the params are present" do
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
