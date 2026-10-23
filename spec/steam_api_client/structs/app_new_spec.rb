require "spec_helper"

RSpec.describe SteamApiClient::Structs::AppNew do
  subject { described_class.new(params) }

  describe "#initialize" do
    let(:params) do
      {
        gid: "6300039510132446959",
        title: "The creator of the canceled Portal 64 demake says, 'Don't be mad at Valve here'",
        url: "https://steamstore-a.akamaihd.net/news/externalpost/PC Gamer/6300039510132446959",
        is_external_url: true,
        author: "Jody Macgregor",
        contents: "Programmer and Nintendo Jedi James Lambert has spe...",
        feedlabel: "PC Gamer",
        date: 1705280078,
        feedname: "PC Gamer",
        feed_type: 0,
        appid: 400,
        tags: nil
      }
    end

    context "when the params are present" do
      it { is_expected.to have_attributes(**params) }
    end
  end
end
