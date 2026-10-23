require "spec_helper"

RSpec.describe SteamApiClient::Structs::Requests::GetAppDetails do
  subject { described_class.new(params) }

  describe "#initialize" do
    let(:params) { {appid: 12345, filters: [], cc: "US", l: "en"} }

    it "initializes with the given appid and other parameters" do
      expect(subject).to have_attributes(appid: 12345, filters: [], cc: "US", l: "en")
    end

    context "when appid is missing" do
      let(:params) { {filters: [], cc: "US", l: "en"} }

      it "raises an error" do
        expect { subject }.to raise_error(Dry::Struct::Error)
      end
    end
  end
end
