require "spec_helper"

RSpec.describe SteamApiClient::Structs::AppDetails::Screenshot do
  subject { described_class.new(params) }

  describe "#initialize" do
    let(:params) do
      {
        id: id,
        path_thumbnail: path_thumbnail,
        path_full: path_full
      }
    end

    context "when the params are present" do
      let(:id) { 0 }
      let(:path_thumbnail) { "https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1174180/ss_66b553f4c209476d3e4ce25fa4714002cc914c4f.600x338.jpg?t=1714055653" }
      let(:path_full) { "https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1174180/ss_66b553f4c209476d3e4ce25fa4714002cc914c4f.1920x1080.jpg?t=1714055653" }

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
