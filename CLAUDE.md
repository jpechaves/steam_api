# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

`steam_api_client` is a Ruby gem wrapping the Steam Web API (`https://api.steampowered.com`) and the Storefront API (`https://store.steampowered.com/api/`). The only runtime dependency is `faraday` (Net::HTTP adapter by default, configurable with `Client.configure { |c| c.adapter = ... }`). Ruby 3.3.4 is used locally (`.ruby-version`); the gemspec requires `>= 3.3` (3.0–3.2 are end-of-life), CI tests 3.3, 3.4 and 4.0.

## Commands

```bash
bin/setup                                    # bundle install
bin/console                                  # IRB with the gem loaded
bin/rspec                                    # full test suite (CI runs `bundle exec rspec`)
bin/rspec spec/steam_api_client/request_spec.rb     # single file
bin/rspec spec/steam_api_client/request_spec.rb:42  # single example by line
bin/rspec --only-failures                    # re-run failures (.rspec_status persistence is enabled)
bin/lint                                     # standardrb --no-fix (target ruby_version 3.3)
bin/standardrb --fix                         # autofix style
bundle exec rubycritic lib --no-browser      # Flay/Flog/Reek analysis (report in tmp/rubycritic; Reek reads .reek.yml)
bundle exec bundler-audit check --update     # known advisories in Gemfile.lock
bin/bump patch|minor|major [--date Y-M-D]    # release PR prep: bump version.rb + Gemfile.lock, move [Unreleased] under the new version
bin/release [--dry-run]                      # publish the gemspec version to RubyGems (MFA prompt) and push tag v<version>; no-op if already released, refuses while [Unreleased] has entries
```

CI (`.github/workflows/ci.yml`) runs three jobs: `lint` (standardrb), `analysis` (RubyCritic with a `--minimum-score` gate; raise it when the score improves) and `test` (rspec matrix). `.github/workflows/audit.yml` runs bundler-audit on push, PRs and weekly. `.github/workflows/changelog.yml` runs `bin/check_changelog`: PRs that touch `lib/` or the gemspec must update `CHANGELOG.md` unless labelled `skip-changelog` (check locally with `bin/check_changelog origin/main`).

SimpleCov runs automatically with the specs and measures `lib/` only (line + branch coverage; CI fails below 98% line / 95% branch, local runs don't). Specs never hit the network: `spec_helper` calls `WebMock.disable_net_connect!`, and requests are stubbed with `stub_request` (exact URL). Real, anonymized Steam responses live in `spec/fixtures/steam/` and run through the pipeline with `parse_steam_fixture` (`spec/support/steam_fixtures.rb`).md`, grouped as Added / Changed / Fixed / Security, with the issue number. CI-, `bin/`- and spec-only changes get no entry.
- PRs never bump the version. A release is its own issue and PR: run `bin/bump patch|minor|major` on a release branch, commit, merge, then run `bin/release` from an up-to-date `main`.
- `bin/` scripts keep their logic in `bin/_*.rb` (`Release`, `Bump`) so it can be tested from `spec/bin/` without running git or touching RubyGems.

## Architecture

Every endpoint is **one declaration** in `lib/steam_api_client/endpoints.rb` (`Endpoints::ALL`) plus, when it returns one, a model:

1. **Endpoint** (`SteamApiClient::Endpoint`) — name (the client method), path (Web API: `"<Interface>/<Method>/<version>/"`, e.g. `"ISteamUser/GetPlayerSummaries/v0002/"`; Storefront: `"appdetails/"` with `api: :store`), `key:` (whether Steam needs the API key, default true), `returns:` (a `Model` type: a model, `[model]` for a list, or a scalar like `:integer`), `at:` (where the result is in Steam's JSON: a key path like `%i[response players]`, or a callable such as `AppDetails.method(:unwrap)`) and `params:`, a Hash of `Endpoint::Param` (`integer`, `integer_list`, `string`, `string_list`, `boolean`; options `default:` (otherwise required), `as:` (Steam's name, e.g. `appid` → `gameid`), `in:` (allowlist)). `Endpoint#query` checks the keyword arguments with Ruby's own messages (`missing keyword: :steamid`, `unknown keyword: :x`), converts them (numeric strings → Integer; lists comma-joined) and raises `ArgumentError` on invalid values.
2. **Requestor** (`SteamApiClient::Requestor`) — `Client` defines one method per `Endpoints::ALL` entry returning a requestor; `retrieve(**params)` runs the request and returns `response.result`.
3. **Model** (`lib/steam_api_client/models/*.rb`, built with `SteamApiClient::Model.define`) — an immutable `Data` class with snake_case fields, e.g. `steam_id: [:integer, from: :steamid]`. Types: `:integer`, `:float`, `:number` (Integer or Float as sent), `:string`, `:boolean` (also Steam's 0/1), another model, or `[type]`; options `from:` (Steam's key or a key path), `optional: true` (nil when Steam leaves the key out), `default:`. Values convert (Steam sends numbers as strings) and `nil` passes through (Steam sends `null`); anything else raises `Model::Error`, whose message names the field but never the value. An empty array where an object is expected reads as nil (Steam's `mac_requirements: []`). Nested parts are built as locals and named with `const_set` (e.g. `AppDetails::Category`). `#to_h` is recursive. `Endpoint#result` turns an empty object (Steam's answer for private data) into nil, and a missing list into `[]`. Live-check `app_details` against a range of apps after changing a model: required non-nil fields once broke 31 of 48 real apps.

Pipeline: `client.<name>.retrieve(**params)` → `SteamApiClient::Request` (`Endpoint#query`, then `Errors::MissingApiToken` if the endpoint needs a key and the client has none, then the URL with `URI.join` and the key first; runs a GET through `Client#connection`, a Faraday connection; Faraday timeouts become `Errors::HttpTimeout` and connection/TLS failures `Errors::ConnectionError`) → `#run` → `SteamApiClient::Response` (wraps the `Faraday::Response`; `#result` parses JSON with symbolized keys into the endpoint's result, raising `Errors::ResponseParseError` with the JSON/`Model::Error` as `cause` when that fails; `#json` is Steam's untouched JSON, what `retrieve_raw` returns) → `FailureHandler.instance.call` raises `SteamApiClient::Errors::*` subclasses of `ApiError` by status code / timeout.

### Adding a new endpoint

- Declare it in `Endpoints::ALL`, and write its model if it returns one (with a real, anonymized fixture spec under `spec/steam_api_client/fixtures/` when possible). Add its exact URL to `spec/steam_api_client/endpoints_spec.rb` and its name to the list in `endpoint_spec.rb`.
- **Register the new model file manually in `lib/steam_api_client.rb`** — there is no autoloading, and require order matters (models used by other models, such as `Game`, first; `endpoints.rb` after every model).
- Every endpoint is a GET with its params in the query string. Steam's POST endpoints (see #88) take form-encoded params; `Request` would need that first.

### Gotchas

- `Client.new` takes a keyword arg: `SteamApiClient::Client.new(api_token: "...")` (the README's positional example is outdated).
- `Client#api_token` returns the instance token, falling back to the class-level `Client.configure` value. The settings are global (a plain `SteamApiClient::Configuration`); `spec_helper` calls `Client.reset_config!` after every example, so specs can call `configure` freely.
- ActiveSupport is not a dependency — don't use `as_json`, `deep_symbolize_keys`, etc. Models' `#to_h` already returns a recursive, symbol-keyed hash.
- SimpleCov loads stdlib gems (e.g. `json`) during specs, which can mask missing requires in `lib/steam_api_client.rb`. Check with `bundle exec ruby -Ilib -e 'require "steam_api_client"; ...'` outside RSpec.
