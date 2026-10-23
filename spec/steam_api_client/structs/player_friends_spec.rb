require "spec_helper"

RSpec.describe SteamApiClient::Structs::PlayerFriends do
  subject(:instance) { described_class.new(params) }

  describe "#initialize" do
    let(:params) { {friendslist: friends_list} }

    context "when the params are present" do
      let(:friends_list) do
        {
          friends: [
            {steamid: "76561198010665131", relationship: "friend", friend_since: 1701205989},
            {steamid: "76561198027904893", relationship: "friend", friend_since: 1701205970}
          ]
        }
      end

      it do
        is_expected.to have_attributes(
          friendslist: have_attributes(
            friends: contain_exactly(
              have_attributes(**friends_list[:friends][0]),
              have_attributes(**friends_list[:friends][1])
            )
          )
        )
      end
    end
  end
end
