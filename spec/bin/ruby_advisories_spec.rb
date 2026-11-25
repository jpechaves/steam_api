require "spec_helper"
require "tmpdir"
require_relative "../../bin/_ruby_advisories"

RSpec.describe RubyAdvisories do
  around do |example|
    Dir.mktmpdir do |database|
      @database = database
      example.run
    end
  end

  def write_advisory(id, yaml)
    directory = File.join(@database, "rubies", "ruby")
    FileUtils.mkdir_p(directory)
    File.write(File.join(directory, "#{id}.yml"), yaml)
  end

  let(:advisories) { described_class.load(@database) }

  before do
    write_advisory("GHSA-3p8q-wmhx-vm2w", <<~YAML)
      ---
      engine: ruby
      ghsa: 3p8q-wmhx-vm2w
      url: https://github.com/ruby/ruby/security/advisories/GHSA-3p8q-wmhx-vm2w
      title: Heap buffer overflow in regular expression compilation
      date: 2026-11-18
      patched_versions:
        - "~> 3.3.14"
        - "~> 3.4.13"
        - ">= 4.0.10"
    YAML
    write_advisory("CVE-2025-24294", <<~YAML)
      ---
      engine: ruby
      cve: 2025-24294
      url: https://www.ruby-lang.org/en/news/2025/07/08/dos-resolv-cve-2025-24294/
      title: Possible Denial of Service in resolv gem
      date: 2025-07-08
      unaffected_versions:
        - "< 3.2.0"
      patched_versions:
        - ">= 3.2.9, < 3.3"
        - ">= 3.3.9"
    YAML
  end

  it "loads every advisory, named after its file" do
    expect(advisories.map(&:id)).to eq(%w[CVE-2025-24294 GHSA-3p8q-wmhx-vm2w])
    expect(advisories.last.to_s).to eq(
      "GHSA-3p8q-wmhx-vm2w: Heap buffer overflow in regular expression compilation " \
      "(patched: ~> 3.3.14 | ~> 3.4.13 | >= 4.0.10) https://github.com/ruby/ruby/security/advisories/GHSA-3p8q-wmhx-vm2w"
    )
  end

  it "returns the advisories affecting a version" do
    expect(described_class.affecting("3.3.4", advisories).map(&:id)).to eq(%w[CVE-2025-24294 GHSA-3p8q-wmhx-vm2w])
    expect(described_class.affecting("3.3.13", advisories).map(&:id)).to eq(%w[GHSA-3p8q-wmhx-vm2w])
    expect(described_class.affecting("4.0.9", advisories).map(&:id)).to eq(%w[GHSA-3p8q-wmhx-vm2w])
  end

  it "leaves out patched versions, unaffected versions and comma-separated ranges" do
    expect(described_class.affecting("3.3.14", advisories)).to be_empty
    expect(described_class.affecting("3.4.13", advisories)).to be_empty
    expect(described_class.affecting("4.0.10", advisories)).to be_empty
    expect(described_class.affecting("3.2.9", advisories).map(&:id)).to eq(%w[GHSA-3p8q-wmhx-vm2w])
    expect(described_class.affecting("3.1.0", advisories).map(&:id)).to eq(%w[GHSA-3p8q-wmhx-vm2w])
  end

  it "raises when the database has no Ruby advisories" do
    expect { described_class.load(File.join(@database, "missing")) }
      .to raise_error(ArgumentError, /No Ruby advisories in .*bundler-audit update/)
  end
end
