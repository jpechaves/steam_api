require "spec_helper"

RSpec.describe SteamApi::Client do
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

  describe "#base_endpoint" do
    subject { described_class.new.base_endpoint }

    it { is_expected.to eql("https://api.steampowered.com") }
  end

  describe "#storefront_endpoint" do
    subject { described_class.new.storefront_endpoint }

    it { is_expected.to eql("https://store.steampowered.com/api/") }
  end
end
