# frozen_string_literal: true

source "https://rubygems.org"

# Specify your gem's dependencies in steam_api_client.gemspec
gemspec

group :development, :test do
  # Ruby's bikeshed-proof linter and formatter.
  # See: [https://rubygems.org/gems/standard]
  gem "standard", "~> 1.4"

  # Code analysis (Flay, Flog, Reek): `bundle exec rubycritic lib`
  # See: [https://rubygems.org/gems/rubycritic]
  gem "rubycritic", "~> 5.0", require: false

  # Known advisories in Gemfile.lock: `bundle exec bundler-audit check --update`
  # See: [https://rubygems.org/gems/bundler-audit]
  gem "bundler-audit", require: false

  # Debugging tool for Ruby.
  # See: [https://rubygems.org/gems/debug]
  gem "debug", "~> 1.9"

  # A Ruby gem to test Ruby code.
  # See: [https://github.com/rspec]
  gem "rspec", "~> 3.4"

  # Stubs HTTP requests and blocks real connections in specs.
  # See: [https://rubygems.org/gems/webmock]
  gem "webmock", "~> 3.34"
end

group :test do
  # A code coverage analysis tool for Ruby.
  # See: [https://rubygems.org/gems/simplecov]
  gem "simplecov", "~> 1.3", require: false
end
