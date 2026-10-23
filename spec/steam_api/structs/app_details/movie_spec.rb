require "spec_helper"

RSpec.describe SteamApi::Structs::AppDetails::Movie do
  subject { described_class.new(params) }

  describe "#initialize" do
    let(:id) { 256692021 }
    let(:name) { "Dota 2 - Join the Battle" }
    let(:thumbnail) { "https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/256692021/movie.293x165.jpg?t=1762820639" }
    let(:highlight) { true }

    context "when the params use the streaming format" do
      let(:params) do
        {
          id: id,
          name: name,
          thumbnail: thumbnail,
          dash_av1: "https://video.akamai.steamstatic.com/store_trailers/570/116737/hash/1749859757/dash_av1.mpd?t=1762820639",
          dash_h264: "https://video.akamai.steamstatic.com/store_trailers/570/116737/hash/1749859757/dash_h264.mpd?t=1762820639",
          hls_h264: "https://video.akamai.steamstatic.com/store_trailers/570/116737/hash/1749859757/hls_264_master.m3u8?t=1762820639",
          highlight: highlight
        }
      end

      it { is_expected.to have_attributes(params) }

      it "does not require the legacy webm and mp4 fields" do
        expect(subject.to_h).not_to include(:webm, :mp4)
      end
    end

    context "when the params use the legacy webm/mp4 format" do
      let(:webm) { {max: "http://cdn.akamai.steamstatic.com/steam/apps/256987122/movie_max_vp9.webm?t=1701872775"} }
      let(:mp4) { {max: "http://cdn.akamai.steamstatic.com/steam/apps/256987122/movie_max.mp4?t=1701872775"} }
      let(:params) { {id: id, name: name, thumbnail: thumbnail, webm: webm, mp4: mp4, highlight: highlight} }

      it do
        is_expected.to have_attributes(
          webm: have_attributes(max: webm[:max]),
          mp4: have_attributes(max: mp4[:max])
        )
      end
    end

    context "when the params are missing" do
      let(:params) { {} }

      it "raises a Dry::Struct::Error" do
        expect { subject }.to raise_error(Dry::Struct::Error)
      end
    end
  end
end
