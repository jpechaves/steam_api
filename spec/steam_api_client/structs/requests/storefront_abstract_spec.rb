require "spec_helper"

RSpec.describe SteamApiClient::Structs::Requests::StorefrontAbstract do
  let(:subclass) do
    Class.new(described_class) do
      def path
        "test_path"
      end
    end
  end

  subject { subclass.new }

  describe "#initialize" do
    it "raises an error when instantiated directly" do
      expect { described_class.new.path }.to raise_error(NoMethodError, /Override this method/)
    end

    it "does not raise an error when instantiated as a subclass" do
      expect { subject }.not_to raise_error
    end
  end

  describe "#body" do
    let(:subclass) do
      Class.new(described_class) do
        attribute :appid, SteamApiClient::Structs::Types::Integer
      end
    end

    it "returns the attributes as a symbolized hash" do
      expect(subclass.new("appid" => 10).body).to eq({appid: 10})
    end
  end
end
