require "spec_helper"
require_relative "../../bin/_release"

RSpec.describe Release do
  # Records every command and answers `capture` calls from a canned table
  let(:fake_shell) do
    Class.new do
      attr_reader :commands

      def initialize(outputs)
        @outputs = outputs
        @commands = []
      end

      def run(command)
        @commands << command
      end

      def capture(command)
        @commands << command
        @outputs.fetch(command) { "" }
      end
    end
  end

  let(:version) { "1.2.3" }
  let(:head) { "abc123" }
  let(:published) { false }
  let(:remote_tag) { "" }
  let(:local_tag) { "" }
  let(:status) { "" }
  let(:changelog) { "## [Unreleased]\n\n## [1.2.3] - 2026-10-23\n" }
  let(:answer) { "y" }
  let(:dry_run) { false }

  let(:shell) do
    fake_shell.new(
      "git status --porcelain --untracked-files=no" => status,
      "git rev-parse HEAD" => "#{head}\n",
      "git ls-remote --tags origin refs/tags/v1.2.3 refs/tags/v1.2.3^{}" => remote_tag,
      "git rev-parse -q --verify refs/tags/v1.2.3^{commit}" => local_tag
    )
  end
  let(:rubygems) { double("rubygems", published?: published) }
  let(:output) { StringIO.new }

  subject(:release) do
    described_class.new(
      shell: shell,
      rubygems: rubygems,
      version: -> { version },
      changelog: -> { changelog },
      confirm: ->(_question) { answer == "y" },
      dry_run: dry_run,
      out: output
    )
  end

  let(:build) { "gem build steam_api_client.gemspec --output pkg/steam_api_client-1.2.3.gem" }
  let(:push) { "gem push pkg/steam_api_client-1.2.3.gem" }
  let(:tag) { "git tag -a v1.2.3 -m \"Release v1.2.3\"" }
  let(:push_tag) { "git push origin v1.2.3" }

  it "updates main before reading the version" do
    release.call

    expect(shell.commands.first(3)).to eq([
      "git status --porcelain --untracked-files=no",
      "git checkout main",
      "git pull --ff-only origin main"
    ])
  end

  context "when the version is new" do
    it "builds, pushes the gem, then tags and pushes the tag" do
      expect(release.call).to eq(:released)
      expect(shell.commands).to include(build, push, tag, push_tag)
      expect(shell.commands.index(push)).to be < shell.commands.index(tag)
    end
  end

  context "when the version is already published and tagged" do
    let(:published) { true }
    let(:remote_tag) { "#{head}\trefs/tags/v1.2.3\n" }

    it "does nothing" do
      expect(release.call).to eq(:already_released)
      expect(shell.commands).not_to include(build, push, tag, push_tag)
      expect(output.string).to include("v1.2.3 is already released")
    end
  end

  context "when the version is released and main has moved on since" do
    let(:published) { true }
    let(:remote_tag) { "tagobj\trefs/tags/v1.2.3\nolder789\trefs/tags/v1.2.3^{}\n" }

    it "does nothing" do
      expect(release.call).to eq(:already_released)
      expect(shell.commands).not_to include(build, push, tag, push_tag)
    end
  end

  context "when the version is published but not tagged" do
    let(:published) { true }

    it "only tags after confirmation" do
      expect(release.call).to eq(:tagged)
      expect(shell.commands).to include(tag, push_tag)
      expect(shell.commands).not_to include(build, push)
    end

    context "and the tag is declined" do
      let(:answer) { "n" }

      it "stops without tagging" do
        expect(release.call).to eq(:aborted)
        expect(shell.commands).not_to include(tag, push_tag)
      end
    end
  end

  context "when the remote annotated tag points to another commit" do
    let(:remote_tag) { "tagobj\trefs/tags/v1.2.3\nother456\trefs/tags/v1.2.3^{}\n" }

    it "aborts before publishing" do
      expect { release.call }.to raise_error(Release::Error, /v1.2.3 already points to other456/)
      expect(shell.commands).not_to include(build, push)
    end
  end

  context "when the tag already exists on origin for this commit but the gem isn't published" do
    let(:remote_tag) { "#{head}\trefs/tags/v1.2.3\n" }

    it "publishes the gem without re-tagging" do
      expect(release.call).to eq(:released)
      expect(shell.commands).to include(build, push)
      expect(shell.commands).not_to include(tag, push_tag)
    end
  end

  context "when the tag exists only locally on this commit" do
    let(:local_tag) { "#{head}\n" }

    it "pushes the existing tag instead of creating it" do
      release.call

      expect(shell.commands).to include(push_tag)
      expect(shell.commands).not_to include(tag)
    end
  end

  context "when there are uncommitted changes" do
    let(:status) { " M lib/steam_api_client.rb\n" }

    it "aborts before touching git" do
      expect { release.call }.to raise_error(Release::Error, /uncommitted changes/)
      expect(shell.commands).not_to include("git checkout main")
    end
  end

  context "when the CHANGELOG has no section for the version" do
    let(:changelog) { "## [Unreleased]\n\n## [1.2.2] - 2026-10-01\n" }

    it "aborts before publishing" do
      expect { release.call }.to raise_error(Release::Error, /CHANGELOG.md has no "## \[1.2.3\]" section/)
      expect(shell.commands).not_to include(build, push)
    end
  end

  context "with a dry run" do
    let(:dry_run) { true }

    it "reports the steps without building, pushing or tagging" do
      expect(release.call).to eq(:released)
      expect(shell.commands).not_to include(build, push, tag, push_tag)
      expect(output.string).to include("[dry run] #{build}", "[dry run] #{push}", "[dry run] #{tag}", "[dry run] #{push_tag}")
    end
  end
end
