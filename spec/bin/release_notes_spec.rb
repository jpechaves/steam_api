require "spec_helper"
require_relative "../../bin/_release_notes"

RSpec.describe ReleaseNotes do
  subject(:result) { described_class.call(changelog: changelog, tag: tag, repo: "owner/repo") }

  let(:tag) { "v1.0.0" }
  let(:changelog) do
    <<~MARKDOWN
      # Changelog

      ## [Unreleased]

      ### Added

      - Something not released yet (#9).

      ## [1.0.0] - 2026-10-24

      ### Added

      - [docs/USAGE.md](docs/USAGE.md), with [Steam's terms](https://steamcommunity.com/dev/apiterms) (#3).

      ## [0.11.0] - 2026-10-23 [YANKED]

      > Yanked: use 1.0.0.

      ## [0.10.0] - 2026-10-23

      ### Changed

      - Faraday (#2).

      [Unreleased]: https://github.com/owner/repo/compare/v1.0.0...HEAD
      [1.0.0]: https://github.com/owner/repo/compare/v0.10.0...v1.0.0
      [0.10.0]: https://github.com/owner/repo/compare/v0.9.1...v0.10.0
    MARKDOWN
  end

  it "returns the version's section, without the heading or other sections" do
    expect(result.notes).to start_with("### Added\n\n- ")
    expect(result.notes).not_to include("## [", "Something not released yet", "Yanked")
  end

  it "links repository files at the tag, and leaves absolute links alone" do
    expect(result.notes).to include(
      "[docs/USAGE.md](https://github.com/owner/repo/blob/v1.0.0/docs/USAGE.md)",
      "[Steam's terms](https://steamcommunity.com/dev/apiterms)"
    )
  end

  it "starts the generated notes from the previous release, skipping yanked versions" do
    expect(result.previous_tag).to eq("v0.10.0")
  end

  context "for the oldest version" do
    let(:tag) { "v0.10.0" }

    it "has no previous tag, and leaves out the compare links at the bottom" do
      expect(result.previous_tag).to be_nil
      expect(result.notes).to eq("### Changed\n\n- Faraday (#2).")
    end
  end

  context "for a yanked version" do
    let(:tag) { "v0.11.0" }

    it "raises" do
      expect { result }.to raise_error(ReleaseNotes::Error, /v0.11.0 was yanked/)
    end
  end

  context "for a version without a section" do
    let(:tag) { "v2.0.0" }

    it "raises" do
      expect { result }.to raise_error(ReleaseNotes::Error, /no "## \[2.0.0\]" section/)
    end
  end
end
