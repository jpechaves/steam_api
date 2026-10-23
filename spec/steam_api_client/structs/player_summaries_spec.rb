require "spec_helper"

RSpec.describe SteamApiClient::Structs::PlayerSummaries do
  subject(:instance) { described_class.new(params) }

  describe "#initialize" do
    let(:params) { {response: {players: players}} }

    context "when the params are present" do
      let(:players) do
        [
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
          },
          {
            steamid: "76561197972495328",
            personaname: "Spitko",
            profileurl: "https://steamcommunity.com/id/FireSlash/",
            avatar: "https://avatars.steamstatic.com/e9e6013d2df1ac9115066c5d9fe20b4a322fac16.jpg",
            avatarmedium: "https://avatars.steamstatic.com/e9e6013d2df1ac9115066c5d9fe20b4a322fac16_medium.jpg",
            avatarfull: "https://avatars.steamstatic.com/e9e6013d2df1ac9115066c5d9fe20b4a322fac16_full.jpg",
            personastate: 1,
            communityvisibilitystate: 3,
            profilestate: 1,
            lastlogoff: nil,
            commentpermission: nil
          }
        ]
      end

      it do
        is_expected.to have_attributes(
          response: have_attributes(
            players: contain_exactly(
              have_attributes(**players[0], steamid: players[0][:steamid].to_i),
              have_attributes(**players[1], steamid: players[1][:steamid].to_i)
            )
          )
        )
      end
    end
  end
end
