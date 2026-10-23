require "spec_helper"

RSpec.describe SteamApiClient::Structs::Requests::GetAppNews do
  subject { described_class.new(params) }

  describe "#initialize" do
    let(:params) { {appid: 12345, count: 5, maxlength: 300} }

    it "initializes with the given appid, count, and maxlength" do
      expect(subject).to have_attributes(appid: 12345, count: 5, maxlength: 300)
    end

    context "when maxlength is missing" do
      let(:params) { {appid: 12345, count: 5} }

      it "raises an error" do
        expect { subject }.to raise_error(Dry::Struct::Error)
      end
    end

    context "when parameters are missing" do
      let(:params) { {} }

      it "raises an error" do
        expect { subject }.to raise_error(Dry::Struct::Error)
      end
    end
  end
end
