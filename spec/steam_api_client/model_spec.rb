require "spec_helper"

RSpec.describe SteamApiClient::Model do
  let(:item) { described_class.define(name: :string, count: [:integer, optional: true]) }
  let(:player) do
    described_class.define(
      steam_id: [:integer, from: :steamid],
      persona_name: [:string, from: :personaname],
      level: [:integer, from: %i[stats level], optional: true],
      tags: [[:string], default: []],
      items: [[item], optional: true],
      best: [item, optional: true]
    )
  end

  describe ".define" do
    it "builds a Data class with the fields as members" do
      expect(player.ancestors).to include(Data)
      expect(player.members).to eq(%i[steam_id persona_name level tags items best])
    end

    it "keeps the block's methods" do
      klass = described_class.define(name: :string) do
        def shout = name.upcase
      end

      expect(klass.from_json({name: "gaben"}).shout).to eq("GABEN")
    end
  end

  describe ".from_json" do
    it "renames Steam's keys, follows paths and builds nested models" do
      player_json = {
        steamid: "76561197960435530", personaname: "Robin", stats: {level: 9}, tags: ["a"],
        items: [{name: "hat"}], best: {name: "cap", count: "2"}, ignored: true
      }

      expect(player.from_json(player_json)).to eq(
        player.new(
          steam_id: 76561197960435530, persona_name: "Robin", level: 9, tags: ["a"],
          items: [item.new(name: "hat", count: nil)], best: item.new(name: "cap", count: 2)
        )
      )
    end

    it "uses nil, or the default, for optional fields Steam leaves out or sends as null" do
      expect(player.from_json({steamid: 1, personaname: "x"})).to have_attributes(level: nil, tags: [], items: nil, best: nil)
      expect(player.from_json({steamid: 1, personaname: "x", tags: nil, stats: {}})).to have_attributes(level: nil, tags: [])
    end

    it "lets nil through required fields (Steam sends null for values it doesn't have)" do
      expect(player.from_json({steamid: nil, personaname: "x"}).steam_id).to be_nil
    end

    it "reads an empty array where an object is expected as none (Steam sends [] for missing requirements)" do
      expect(player.from_json({steamid: 1, personaname: "x", best: []}).best).to be_nil
    end

    it "raises Model::Error, naming the field, when a required key is missing" do
      expect { player.from_json({steamid: 1}) }.to raise_error(described_class::Error, "persona_name: missing key :personaname")
    end

    it "raises Model::Error with the path to a nested invalid value" do
      expect { player.from_json({steamid: 1, personaname: "x", items: [{name: "a"}, {name: {}}]}) }
        .to raise_error(described_class::Error, "items: name: expected a String, got Hash")
    end

    it "raises Model::Error when the JSON isn't an object" do
      expect { player.from_json([1]) }.to raise_error(described_class::Error, "expected an object, got Array")
      expect { player.from_json({steamid: 1, personaname: "x", tags: "a"}) }.to raise_error(described_class::Error, "tags: expected a list, got String")
    end

    it "never shows the invalid value itself, which could be personal data" do
      expect { player.from_json({steamid: "Robin Walker", personaname: "x"}) }
        .to raise_error(described_class::Error, "steam_id: expected an Integer, got String")
    end
  end

  # Steam often sends numbers as strings, so scalars convert, but anything that
  # can't be converted raises instead of passing through
  describe ".cast" do
    def cast(type, value) = described_class.cast(type, value)

    it "converts integers, from numeric strings too" do
      expect([cast(:integer, 17), cast(:integer, "17"), cast(:integer, "-3")]).to eq([17, 17, -3])
      expect { cast(:integer, "seventeen") }.to raise_error(described_class::Error)
      expect { cast(:integer, 1.5) }.to raise_error(described_class::Error)
      expect { cast(:integer, true) }.to raise_error(described_class::Error)
    end

    it "converts floats, from integers and numeric strings too" do
      expect([cast(:float, "49.6"), cast(:float, 5.099999904632568), cast(:float, 3)]).to eq([49.6, 5.099999904632568, 3.0])
      expect(cast(:float, 3)).to be_a(Float)
      expect { cast(:float, "n/a") }.to raise_error(described_class::Error)
    end

    it "keeps numbers as Steam sends them for :number, converting numeric strings" do
      expect([cast(:number, 26580), cast(:number, 0.5), cast(:number, "7"), cast(:number, "7.5")]).to eq([26580, 0.5, 7, 7.5])
      expect { cast(:number, "x") }.to raise_error(described_class::Error)
    end

    it "converts numbers to strings" do
      expect([cast(:string, "a"), cast(:string, 1)]).to eq(%w[a 1])
      expect { cast(:string, {name: "x"}) }.to raise_error(described_class::Error)
    end

    it "accepts true/false and Steam's 0/1 flags as booleans" do
      expect([cast(:boolean, true), cast(:boolean, false), cast(:boolean, 1), cast(:boolean, 0)]).to eq([true, false, true, false])
      expect { cast(:boolean, "yes") }.to raise_error(described_class::Error)
      expect { cast(:boolean, 2) }.to raise_error(described_class::Error)
    end

    it "converts each element of a list" do
      expect(cast([:integer], ["1", 2])).to eq([1, 2])
    end

    it "lets nil through every type" do
      expect([:integer, :float, :number, :string, :boolean, [:integer], item].map { |type| cast(type, nil) }).to all(be_nil)
    end

    it "rejects unknown types" do
      expect { cast(:date, "x") }.to raise_error(ArgumentError, /unknown type :date/)
    end
  end

  describe "#to_h" do
    it "converts nested models and lists into plain hashes" do
      built = player.from_json({steamid: 1, personaname: "x", items: [{name: "hat"}], best: {name: "cap"}})

      expect(built.to_h).to eq(
        steam_id: 1, persona_name: "x", level: nil, tags: [], items: [{name: "hat", count: nil}], best: {name: "cap", count: nil}
      )
    end
  end

  it "builds frozen values with value equality and pattern matching" do
    built = item.from_json({name: "hat", count: 1})

    expect(built).to be_frozen.and(eq(item.from_json({name: "hat", count: "1"})))
    expect(built.deconstruct_keys([:name])).to eq(name: "hat")
    matched = case built
    in {name: "hat", count: Integer} then true
    end
    expect(matched).to be(true)
  end
end
