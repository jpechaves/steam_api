require "spec_helper"
require_relative "../../bin/_changelog_check"

RSpec.describe ChangelogCheck do
  subject(:result) { described_class.call(changed_files: changed_files, labels: labels) }

  let(:labels) { [] }

  context "when lib/ changes without a CHANGELOG entry" do
    let(:changed_files) { ["lib/steam_api_client/request.rb", "spec/steam_api_client/request_spec.rb"] }

    it "fails and explains how to fix or skip it" do
      expect(result).not_to be_ok
      expect(result.message).to include("lib/steam_api_client/request.rb", "## [Unreleased]", "skip-changelog")
    end

    context "and the PR has the skip-changelog label" do
      let(:labels) { ["enhancement", "skip-changelog"] }

      it { is_expected.to be_ok }
    end
  end

  context "when the gemspec changes without a CHANGELOG entry" do
    let(:changed_files) { ["steam_api_client.gemspec"] }

    it { is_expected.not_to be_ok }
  end

  context "when lib/ changes together with the CHANGELOG" do
    let(:changed_files) { ["lib/steam_api_client/request.rb", "CHANGELOG.md"] }

    it { is_expected.to be_ok }
  end

  context "when only internal files change" do
    let(:changed_files) { ["bin/release", ".github/workflows/ci.yml", "spec/spec_helper.rb", "README.md", "CLAUDE.md"] }

    it "passes without a CHANGELOG entry" do
      expect(result).to be_ok
      expect(result.message).to include("No user-visible files changed")
    end
  end
end
