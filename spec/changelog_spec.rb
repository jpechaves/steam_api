require "spec_helper"

# Guards CHANGELOG.md's structure: Keep a Changelog groups each version's
# entries under one heading per kind of change
RSpec.describe "CHANGELOG.md" do
  changelog = File.read(File.expand_path("../CHANGELOG.md", __dir__))
  versions = changelog.split(/^(?=## \[)/).grep(/\A## \[/)

  it "has version sections" do
    expect(versions.map { |section| section[/\A## \[([^\]]+)\]/, 1] }).to include("Unreleased", "0.10.0", "0.9.0")
  end

  versions.each do |section|
    version = section[/\A## \[([^\]]+)\]/, 1]

    it "uses each heading at most once in [#{version}]" do
      headings = section.scan(/^### (.+)$/).flatten

      expect(headings.tally.select { |_, count| count > 1 }.keys).to be_empty
    end
  end
end
