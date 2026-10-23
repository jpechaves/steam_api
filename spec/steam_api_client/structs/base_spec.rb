require "spec_helper"

RSpec.describe SteamApiClient::Structs::Base do
  let(:klass) do
    Class.new(described_class) do
      attribute :name, SteamApiClient::Structs::Types::String
      attribute :options, SteamApiClient::Structs::Types::Hash.schema(
        foo: SteamApiClient::Structs::Types::String.optional.default("Default foo".freeze),
        bar: SteamApiClient::Structs::Types::String
      )
    end
  end

  describe ".build_from_response" do
    subject { klass.build_from_response(response) }

    context "when the response is valid" do
      context "and have no optional response params missing" do
        let(:response) { {name: "Steam", options: {foo: "Custom foo", bar: "Custom bar"}} }

        it "builds an instance with valid response" do
          expect(subject).to be_a(klass)
          expect(subject.name).to eq("Steam")
          expect(subject.options).to eq({foo: "Custom foo", bar: "Custom bar"})
        end
      end

      context "and have optional response params missing" do
        let(:response) { {name: "Gabe", options: {bar: "Custom bar"}} }

        it "uses default values for missing response" do
          expect(subject).to be_a(klass)
          expect(subject.name).to eq("Gabe")
          expect(subject.options).to eq({foo: "Default foo", bar: "Custom bar"})
        end
      end
    end

    context "when the response is invalid" do
      let(:response) { {name: "Newell", options: {baz: "Invalid"}} }

      it "raises an error for invalid response" do
        expect { subject }.to raise_error(Dry::Struct::Error)
      end
    end
  end
end
