require "spec_helper"

RSpec.describe SteamApiClient::Configuration do
  subject(:config) { described_class.new }

  it "has no token, 10s / 5s timeouts and the Net::HTTP adapter by default" do
    expect(config).to have_attributes(api_token: nil, timeout: 10, connect_timeout: 5, adapter: :net_http)
  end

  it "lets every setting be changed" do
    config.api_token = "token"
    config.timeout = 30
    config.connect_timeout = 2
    config.adapter = :test

    expect(config).to have_attributes(api_token: "token", timeout: 30, connect_timeout: 2, adapter: :test)
  end

  it "returns the settings as a Hash" do
    expect(config.to_h).to eq(api_token: nil, timeout: 10, connect_timeout: 5, adapter: :net_http)
  end

  it "keeps the token out of #inspect" do
    config.api_token = "SECRET-TOKEN-123"

    expect(config.inspect).to eq(
      "#<SteamApiClient::Configuration api_token=[REDACTED] timeout=10 connect_timeout=5 adapter=:net_http>"
    )
  end
end

RSpec.describe SteamApiClient::Client do
  describe ".config" do
    it "is a Configuration shared by every client" do
      expect(described_class.config).to be_a(SteamApiClient::Configuration).and(be(described_class.config))
    end
  end

  describe ".configure" do
    it "yields the configuration and returns the class" do
      expect { |block| described_class.configure(&block) }.to yield_with_args(described_class.config)
      expect(described_class.configure { |config| config.timeout = 3 }).to be(described_class)
    end
  end

  describe ".reset_config!" do
    it "restores the defaults" do
      described_class.configure do |config|
        config.api_token = "token"
        config.timeout = 30
      end

      described_class.reset_config!

      expect(described_class.config).to have_attributes(api_token: nil, timeout: 10)
    end
  end

  it "keeps the DEFAULT_* constants" do
    expect(described_class::DEFAULT_TIMEOUT).to eq(10)
    expect(described_class::DEFAULT_CONNECT_TIMEOUT).to eq(5)
    expect(described_class::DEFAULT_ADAPTER).to eq(:net_http)
  end

  it "no longer depends on dry-configurable" do
    expect(described_class.singleton_class.ancestors.map(&:name)).not_to include("Dry::Configurable")
  end
end
