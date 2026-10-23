require "spec_helper"

RSpec.describe SteamApiClient::Client do
  let(:api_key) { "random-api-key-value" }

  describe "#configure" do
    subject do
      described_class.configure do |config|
        config.api_token = api_key
      end
    end

    after { described_class.config.api_token = nil }

    it "allows configuring the client through a block" do
      expect(subject.config.api_token).to eql(api_key)
    end
  end

  describe "#api_token" do
    after { described_class.config.api_token = nil }

    it "returns the token given to the instance" do
      expect(described_class.new(api_token: api_key).api_token).to eql(api_key)
    end

    it "falls back to the configured token" do
      described_class.configure { |config| config.api_token = api_key }

      expect(described_class.new.api_token).to eql(api_key)
    end

    it "prefers the instance token over the configured one" do
      described_class.configure { |config| config.api_token = "configured" }

      expect(described_class.new(api_token: api_key).api_token).to eql(api_key)
    end
  end

  describe "timeouts" do
    after do
      described_class.config.timeout = described_class::DEFAULT_TIMEOUT
      described_class.config.connect_timeout = described_class::DEFAULT_CONNECT_TIMEOUT
    end

    it "defaults to 10s total and 5s to connect" do
      client = described_class.new

      expect(client).to have_attributes(timeout: 10, connect_timeout: 5)
    end

    it "falls back to the configured timeouts" do
      described_class.configure do |config|
        config.timeout = 30
        config.connect_timeout = 2
      end

      expect(described_class.new).to have_attributes(timeout: 30, connect_timeout: 2)
    end

    it "prefers the timeouts given to the instance" do
      described_class.configure { |config| config.timeout = 30 }

      client = described_class.new(timeout: 1.5, connect_timeout: 0.5)

      expect(client).to have_attributes(timeout: 1.5, connect_timeout: 0.5)
    end
  end

  describe "adapter" do
    after { described_class.config.adapter = described_class::DEFAULT_ADAPTER }

    it "defaults to Faraday's Net::HTTP adapter" do
      expect(described_class.new.adapter).to eq(:net_http)
    end

    it "falls back to the configured adapter" do
      described_class.configure { |config| config.adapter = :test }

      expect(described_class.new.adapter).to eq(:test)
    end

    it "prefers the adapter given to the instance" do
      described_class.configure { |config| config.adapter = :test }

      expect(described_class.new(adapter: :net_http).adapter).to eq(:net_http)
    end

    it "builds one Faraday connection with that adapter" do
      client = described_class.new

      expect(client.connection).to be_a(Faraday::Connection).and(be(client.connection))
      expect(client.connection.builder.adapter).to eq(Faraday::Adapter::NetHttp)
    end
  end

  describe "#base_endpoint" do
    subject { described_class.new.base_endpoint }

    it { is_expected.to eql("https://api.steampowered.com") }
  end

  describe "#storefront_endpoint" do
    subject { described_class.new.storefront_endpoint }

    it { is_expected.to eql("https://store.steampowered.com/api/") }
  end
end
