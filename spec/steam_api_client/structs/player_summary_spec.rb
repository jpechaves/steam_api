require "spec_helper"

RSpec.describe SteamApiClient::Structs::PlayerSummary do
  subject(:instance) { described_class.new(params) }

  describe "#initialize" do
    let(:params) do
      {
        steamid: "76561198063576425",
        personaname: "Volmer",
        profileurl: "https://steamcommunity.com/id/georgevolmer/",
        avatar: "https://avatars.steamstatic.com/a4f2eb3733ac79b354b36a7a5af71a1b3ca10493.jpg",
        avatarmedium: "https://avatars.steamstatic.com/a4f2eb3733ac79b354b36a7a5af71a1b3ca10493_medium.jpg",
        avatarfull: "https://avatars.steamstatic.com/a4f2eb3733ac79b354b36a7a5af71a1b3ca10493_full.jpg",
        personastate: 1,
        communityvisibilitystate: 3,
        profilestate: 1,
        lastlogoff: 1713070291,
        commentpermission: 1
      }
    end

    context "when the params are present" do
      it { is_expected.to have_attributes(**params) }
    end
  end
end
