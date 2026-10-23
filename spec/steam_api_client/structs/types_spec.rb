require "spec_helper"

RSpec.describe SteamApiClient::Structs::Types do
  # Steam often sends numbers as strings, so scalars coerce, but anything
  # that can't be coerced is rejected instead of passing through untouched
  describe "Integer" do
    it "coerces numeric strings" do
      expect(described_class::Integer["17"]).to eq(17)
      expect(described_class::Integer[76561197960435530]).to eq(76561197960435530)
    end

    it "rejects values that aren't integers" do
      expect { described_class::Integer["seventeen"] }.to raise_error(Dry::Types::CoercionError)
    end
  end

  describe "String" do
    it "coerces numbers" do
      expect(described_class::String[1]).to eq("1")
    end

    it "rejects values that aren't strings or numbers" do
      expect { described_class::String[{name: "x"}] }.to raise_error(Dry::Types::ConstraintError)
    end
  end

  describe "Float" do
    it "coerces numeric strings and floats" do
      expect(described_class::Float["49.6"]).to eq(49.6)
      expect(described_class::Float[5.099999904632568]).to eq(5.099999904632568)
    end

    it "rejects values that aren't numbers" do
      expect { described_class::Float["n/a"] }.to raise_error(Dry::Types::CoercionError)
    end
  end

  describe "Bool" do
    it "accepts only true and false" do
      expect(described_class::Bool[true]).to be(true)
      expect { described_class::Bool["yes"] }.to raise_error(Dry::Types::ConstraintError)
    end
  end

  # Steam sends null for values it doesn't have (e.g. an app's website), so
  # nil passes through every scalar type instead of being coerced or rejected
  describe "nil" do
    it "passes through unchanged" do
      expect([described_class::Integer, described_class::Float, described_class::String, described_class::Bool].map { |type| type[nil] }).to all(be_nil)
    end
  end

  describe "Array.of" do
    it "applies the member type to each element" do
      expect(described_class::Array.of(described_class::Integer)[["1", 2]]).to eq([1, 2])
    end
  end

  describe "Optional" do
    it "defaults to nil and coerces present values" do
      expect(described_class::Optional::Integer[nil]).to be_nil
      expect(described_class::Optional::Integer["5"]).to eq(5)
      expect(described_class::Optional::String[nil]).to be_nil
    end
  end
end
