require "spec_helper"

RSpec.describe "Response struct hierarchy" do
  structs = ObjectSpace.each_object(Class).select { |klass| klass < Dry::Struct && klass.name&.start_with?("SteamApiClient::Structs::") }
  # Request structs and the nested attribute blocks dry-struct generates (e.g. PlayerFriends::Friendslist) are out of scope
  named = structs.reject { |klass| klass.name.include?("::Requests::") || klass == SteamApiClient::Structs::Base }
  named = named.select { |klass| klass.name.split("::").last.match?(/\AInternal|\AAppNew\z|\APlayerSummary\z/) }

  it "covers the nested element structs" do
    expect(named.map(&:name)).to include("SteamApiClient::Structs::InternalPlayerFriends", "SteamApiClient::Structs::PlayerSummary", "SteamApiClient::Structs::AppNew")
  end

  named.each do |klass|
    it "#{klass.name} inherits from Structs::Base" do
      expect(klass.ancestors).to include(SteamApiClient::Structs::Base)
    end
  end

  it "accepts string keys like the other structs (Base transforms them to symbols)" do
    friend = SteamApiClient::Structs::InternalPlayerFriends.new("steamid" => "76561197960265731", "relationship" => "friend", "friend_since" => 0)

    expect(friend).to have_attributes(steamid: 76561197960265731, relationship: "friend", friend_since: 0)
  end
end
