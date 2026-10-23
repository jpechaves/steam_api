require "spec_helper"
require "tmpdir"
require_relative "../../bin/_bump"

RSpec.describe Bump do
  let(:changelog) do
    <<~MD
      # Changelog

      ## [Unreleased]

      ### Fixed

      - Something users will notice (#1).

      ## [0.9.1] - 2026-10-23

      - Older entry.

      [Unreleased]: https://github.com/jpechaves/steam_api/compare/v0.9.1...HEAD
      [0.9.1]: https://github.com/jpechaves/steam_api/compare/v0.9.0...v0.9.1
    MD
  end

  describe ".next_version" do
    it "bumps patch, minor and major" do
      expect(described_class.next_version("0.9.1", "patch")).to eq("0.9.2")
      expect(described_class.next_version("0.9.1", "minor")).to eq("0.10.0")
      expect(described_class.next_version("0.9.1", "major")).to eq("1.0.0")
    end

    it "rejects unknown levels" do
      expect { described_class.next_version("0.9.1", "huge") }.to raise_error(Bump::Error, /patch, minor or major/)
    end
  end

  describe ".version_file" do
    it "replaces the VERSION constant" do
      source = %(module SteamApiClient\n  VERSION = "0.9.1"\nend\n)

      expect(described_class.version_file(source, "0.9.2")).to eq(%(module SteamApiClient\n  VERSION = "0.9.2"\nend\n))
    end
  end

  describe ".lockfile" do
    it "replaces the gem's own entry only" do
      lock = "PATH\n  remote: .\n  specs:\n    steam_api_client (0.9.1)\n      typhoeus (~> 1.4)\n\nDEPENDENCIES\n  steam_api_client!\n"

      expect(described_class.lockfile(lock, "0.9.1", "0.9.2")).to eq(lock.sub("steam_api_client (0.9.1)", "steam_api_client (0.9.2)"))
    end
  end

  describe ".changelog" do
    subject(:bumped) { described_class.changelog(changelog, from: "0.9.1", to: "0.9.2", date: "2026-11-01") }

    it "moves the Unreleased entries under the new version and keeps an empty Unreleased" do
      expect(bumped).to include(<<~MD)
        ## [Unreleased]

        ## [0.9.2] - 2026-11-01

        ### Fixed

        - Something users will notice (#1).

        ## [0.9.1] - 2026-10-23
      MD
    end

    it "updates the compare links" do
      expect(bumped).to end_with(<<~MD)
        [Unreleased]: https://github.com/jpechaves/steam_api/compare/v0.9.2...HEAD
        [0.9.2]: https://github.com/jpechaves/steam_api/compare/v0.9.1...v0.9.2
        [0.9.1]: https://github.com/jpechaves/steam_api/compare/v0.9.0...v0.9.1
      MD
    end

    context "when Unreleased is empty" do
      let(:changelog) { "## [Unreleased]\n\n## [0.9.1] - 2026-10-23\n\n- Older entry.\n" }

      it "refuses to bump" do
        expect { bumped }.to raise_error(Bump::Error, /nothing under \[Unreleased\]/)
      end
    end
  end

  describe ".call" do
    around do |example|
      Dir.mktmpdir do |root|
        @root = root
        FileUtils.mkdir_p(File.join(root, "lib/steam_api_client"))
        File.write(File.join(root, "lib/steam_api_client/version.rb"), %(module SteamApiClient\n  VERSION = "0.9.1"\nend\n))
        File.write(File.join(root, "Gemfile.lock"), "  specs:\n    steam_api_client (0.9.1)\n")
        File.write(File.join(root, "CHANGELOG.md"), changelog)
        example.run
      end
    end

    let(:output) { StringIO.new }

    it "updates the version, lockfile and CHANGELOG and returns the new version" do
      expect(described_class.call(level: "minor", root: @root, date: "2026-11-01", out: output)).to eq("0.10.0")

      expect(File.read(File.join(@root, "lib/steam_api_client/version.rb"))).to include(%(VERSION = "0.10.0"))
      expect(File.read(File.join(@root, "Gemfile.lock"))).to include("steam_api_client (0.10.0)")
      expect(File.read(File.join(@root, "CHANGELOG.md"))).to include("## [0.10.0] - 2026-11-01")
      expect(output.string).to include("0.9.1 → 0.10.0", "bin/release")
    end

    it "writes nothing when the CHANGELOG can't be bumped" do
      File.write(File.join(@root, "CHANGELOG.md"), "## [Unreleased]\n\n## [0.9.1] - 2026-10-23\n")

      expect { described_class.call(level: "patch", root: @root, date: "2026-11-01", out: output) }.to raise_error(Bump::Error)
      expect(File.read(File.join(@root, "lib/steam_api_client/version.rb"))).to include(%(VERSION = "0.9.1"))
    end
  end
end
