require "spec_helper"

RSpec.describe SteamApiClient::Endpoint do
  param = SteamApiClient::Endpoint::Param

  let(:endpoint) do
    described_class.new(
      :example, "IExample/GetThing/v1/",
      returns: SteamApiClient::Structs::PlayerLevel,
      params: {
        steamid: param.integer,
        appids: param.integer_list,
        flag: param.boolean(default: false),
        relationship: param.string(default: "all", in: %w[all friend]),
        country_code: param.string(as: :cc, default: "US"),
        tags: param.string_list(default: [])
      }
    )
  end

  describe "#query" do
    it "converts the params for the query string, applying defaults and renames, in declaration order" do
      expect(endpoint.query(steamid: 1, appids: [440, "570"])).to eq(
        steamid: 1, appids: "440,570", flag: false, relationship: "all", cc: "US", tags: ""
      )
    end

    it "coerces numeric strings to integers" do
      expect(endpoint.query(steamid: "76561197960435530", appids: ["1"])).to include(steamid: 76561197960435530, appids: "1")
    end

    it "joins string lists" do
      expect(endpoint.query(steamid: 1, appids: [1], tags: %w[basic price_overview])).to include(tags: "basic,price_overview")
    end

    it "raises like Ruby when required keywords are missing" do
      expect { endpoint.query(appids: [1]) }.to raise_error(ArgumentError, "missing keyword: :steamid")
      expect { endpoint.query({}) }.to raise_error(ArgumentError, "missing keywords: :steamid, :appids")
    end

    it "raises like Ruby on unknown keywords" do
      expect { endpoint.query(steamid: 1, appids: [1], steam_id: 2) }.to raise_error(ArgumentError, "unknown keyword: :steam_id")
    end

    it "raises ArgumentError on values that don't convert" do
      expect { endpoint.query(steamid: "abc", appids: [1]) }.to raise_error(ArgumentError, /steamid must be an Integer, got "abc"/)
      expect { endpoint.query(steamid: nil, appids: [1]) }.to raise_error(ArgumentError, /steamid must be an Integer, got nil/)
      expect { endpoint.query(steamid: 1.5, appids: [1]) }.to raise_error(ArgumentError, /steamid must be an Integer, got 1.5/)
      expect { endpoint.query(steamid: 1, appids: [1], flag: "yes") }.to raise_error(ArgumentError, /flag must be true or false, got "yes"/)
      expect { endpoint.query(steamid: 1, appids: [1], relationship: 3) }.to raise_error(ArgumentError, /relationship must be a String, got 3/)
      expect { endpoint.query(steamid: 1, appids: 440) }.to raise_error(ArgumentError, /appids must be an Array, got 440/)
    end

    it "only allows the listed values" do
      expect { endpoint.query(steamid: 1, appids: [1], relationship: "enemy") }
        .to raise_error(ArgumentError, 'relationship must be one of "all", "friend", got "enemy"')
    end
  end

  describe SteamApiClient::Endpoint::Param do
    it "rejects unknown types" do
      expect { described_class.new(:float) }.to raise_error(ArgumentError, /type must be one of/)
    end

    it "is required without a default" do
      expect(described_class.integer).to be_required
      expect(described_class.integer(default: nil)).not_to be_required
    end
  end

  describe "#key?" do
    it "needs the API key unless told otherwise" do
      expect(endpoint.key?).to be(true)
      expect(described_class.new(:x, "I/M/v1/", returns: Object, key: false).key?).to be(false)
    end
  end

  describe "#api" do
    it "is the Web API by default, or the Storefront" do
      expect(endpoint.api).to eq(:web)
      expect(described_class.new(:x, "appdetails/", api: :store, returns: Object).api).to eq(:store)
    end

    it "rejects other APIs" do
      expect { described_class.new(:x, "x/", api: :community, returns: Object) }.to raise_error(ArgumentError, /api must be :web or :store/)
    end
  end

  it "is frozen" do
    expect(endpoint).to be_frozen
    expect(endpoint.params).to be_frozen
  end
end

RSpec.describe SteamApiClient::Endpoints do
  it "declares every endpoint the client exposes, by name" do
    expect(described_class::ALL.keys).to contain_exactly(
      :app_details, :app_global_achievements, :app_news, :game_current_players, :player_achievements,
      :player_friends, :player_game_stats, :player_level, :player_owned_games, :player_recent_games,
      :player_steamid, :player_summaries
    )
    expect(described_class::ALL).to all(satisfy { |name, endpoint| endpoint.name == name })
  end

  it "only uses the API key where Steam needs it" do
    keyless = described_class::ALL.values.reject(&:key?).map(&:name)

    expect(keyless).to contain_exactly(:app_details, :app_global_achievements, :app_news, :game_current_players)
  end
end

RSpec.describe SteamApiClient::Requestor do
  let(:client) { SteamApiClient::Client.new(api_token: "test-key") }

  it "is what the client exposes for every endpoint" do
    SteamApiClient::Endpoints::ALL.each do |name, endpoint|
      expect(client.public_send(name)).to be_a(described_class).and(have_attributes(endpoint: endpoint))
    end
  end

  it "keeps one requestor per endpoint and client" do
    expect(client.player_level).to be(client.player_level)
  end

  it "only takes keyword arguments" do
    expect { client.player_level.retrieve(1) }.to raise_error(ArgumentError)
  end

  it "shows its endpoint in #inspect, not the client" do
    expect(client.player_level.inspect).to eq("#<SteamApiClient::Requestor player_level IPlayerService/GetSteamLevel/v0001/>")
  end
end
