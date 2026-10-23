require "spec_helper"

# Guards the SimpleCov setup in spec_helper: only the gem's lib/ is measured
RSpec.describe "Coverage configuration" do
  # A file is reported when it matches a `cover` pattern and no `skip` filter
  def measured?(path)
    source_file = SimpleCov::SourceFile.new(File.expand_path(path, SimpleCov.root), {"lines" => []})
    SimpleCov.cover_filters.any? { |filter| filter.matches?(source_file) } &&
      SimpleCov.filters.none? { |filter| filter.matches?(source_file) }
  end

  it "measures the gem's code" do
    expect(measured?("lib/steam_api_client/request.rb")).to be(true)
  end

  it "ignores specs and bin/ tooling" do
    expect(measured?("spec/steam_api_client/request_spec.rb")).to be(false)
    expect(measured?("bin/_release.rb")).to be(false)
  end

  it "ignores version.rb, which Bundler loads before SimpleCov starts" do
    expect(measured?("lib/steam_api_client/version.rb")).to be(false)
  end
end
