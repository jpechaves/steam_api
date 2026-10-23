require "spec_helper"

RSpec.describe SteamApiClient::Structs::Requests::Abstract do
  let(:subclass) do
    Class.new(described_class) do
      def version
        "v1"
      end

      def interface
        "TestInterface"
      end

      def path
        "test_path"
      end
    end
  end

  subject { subclass.new }

  describe "#initialize" do
    it "raises an error when instantiated directly" do
      expect { described_class.new.version }.to raise_error(NoMethodError, /Override this method/)
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

  describe "defaults" do
    it "requires subclasses to define interface and path" do
      expect { described_class.new.interface }.to raise_error(NoMethodError, /Override this method/)
      expect { described_class.new.path }.to raise_error(NoMethodError, /Override this method/)
    end

    it "is a GET without query params" do
      expect(subject).to have_attributes(method: :get, query_params: {})
    end
  end
end
