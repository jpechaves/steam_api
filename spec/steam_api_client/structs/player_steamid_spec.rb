require "spec_helper"

RSpec.describe SteamApiClient::Structs::PlayerSteamId do
  subject { described_class.new(params) }

  describe "#initialize" do
    let(:params) do
      {
        response: {
          steamid: steam_id,
          message: message,
          success: success
        }
      }
    end

    context "when all params are present" do
      let(:steam_id) { 76561198160009756 }
      let(:message) { "Success" }
      let(:success) { 1 }

      it { is_expected.to have_attributes(response: have_attributes(**params[:response])) }
    end

    context "when some params are missing" do
      let(:steam_id) { nil }
      let(:message) { nil }
      let(:success) { 42 }

      it { is_expected.to have_attributes(response: have_attributes(**params[:response])) }
    end
  end
end
