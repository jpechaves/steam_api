require "spec_helper"

RSpec.describe "steam_api_client.gemspec" do
  subject(:gemspec) { Gem::Specification.load(File.expand_path("../../steam_api_client.gemspec", __dir__)) }

  it "packages only the library code and its docs" do
    expect(gemspec.files).to all(match(%r{\A(?:lib/.+\.rb|LICENSE|README\.md|CHANGELOG\.md)\z}))
  end

  it "includes the entry point, the version file and the docs" do
    expect(gemspec.files).to include(
      "lib/steam_api_client.rb",
      "lib/steam_api_client/version.rb",
      "LICENSE",
      "README.md",
      "CHANGELOG.md"
    )
  end

  it "points the homepage to the GitHub repository" do
    expect(gemspec.homepage).to eq("https://github.com/jpechaves/steam_api")
    expect(gemspec.metadata["homepage_uri"]).to eq(gemspec.homepage)
  end

  it "requires a maintained Ruby (3.3 or newer)" do
    expect(gemspec.required_ruby_version).to eq(Gem::Requirement.new(">= 3.3"))
  end

  it "allows compatible updates of its runtime dependencies" do
    requirements = gemspec.runtime_dependencies.to_h { |dependency| [dependency.name, dependency.requirement.to_s] }

    expect(requirements).to eq("dry-configurable" => "~> 1.1", "dry-struct" => "~> 1.6", "faraday" => "~> 2.0")
  end

  it "ships no executables" do
    expect(gemspec.executables).to be_empty
  end
end
