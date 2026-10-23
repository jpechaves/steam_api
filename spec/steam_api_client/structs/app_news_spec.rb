require "spec_helper"

RSpec.describe SteamApiClient::Structs::AppNews do
  subject { described_class.new(params) }

  describe "#initialize" do
    let(:params) do
      {
        appnews: {
          appid: app_id,
          count: count,
          newsitems: [item]
        }
      }
    end

    context "when the params are present" do
      let(:app_id) { 400 }
      let(:count) { 2 }
      let(:item) do
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

      it { is_expected.to have_attributes(appnews: have_attributes(appid: app_id)) }

      it { is_expected.to have_attributes(appnews: have_attributes(count: count)) }

      it do
        is_expected.to have_attributes(
          appnews: have_attributes(
            newsitems: contain_exactly(
              have_attributes(**item)
            )
          )
        )
      end
    end
  end
end
