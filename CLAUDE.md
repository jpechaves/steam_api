# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

`steam_api_client` is a Ruby gem wrapping the Steam Web API (`https://api.steampowered.com`) and the Storefront API (`https://store.steampowered.com/api/`). Runtime dependencies are only `dry-configurable`, `dry-struct`, and `typhoeus`. Ruby 3.3.4 is used locally (`.ruby-version`); the gemspec allows `>= 3.0`, CI tests 3.2 and 3.3.

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
bin/release [--dry-run]                      # publish the gemspec version to RubyGems (MFA prompt) and push tag v<version>; no-op if already released
```

CI (`.github/workflows/ci.yml`) runs three jobs: `lint` (standardrb), `analysis` (RubyCritic with a `--minimum-score` gate; raise it when the score improves) and `test` (rspec matrix). `.github/workflows/audit.yml` runs bundler-audit on push, PRs and weekly.

SimpleCov runs automatically with the specs. Specs never hit the network: they stub `Typhoeus::Request`/responses with `instance_double`.

## Changelog & releases

- Every PR with a user-visible change (`lib/` or the gemspec) adds a line under `## [Unreleased]` in `CHANGELOG.md`, grouped as Added / Changed / Fixed / Security, with the issue number. CI-, `bin/`- and spec-only changes get no entry.
- PRs never bump the version. A release is its own issue and PR: run `bin/bump patch|minor|major` on a release branch, commit, merge, then run `bin/release` from an up-to-date `main`.
- `bin/` scripts keep their logic in `bin/_*.rb` (`Release`, `Bump`) so it can be tested from `spec/bin/` without running git or touching RubyGems.

## Architecture

Every endpoint is implemented as three pieces wired together through a shared pipeline:

1. **Requestor** (`lib/steam_api_client/requestors/*.rb`, subclass of `Requestors::Base`) — the public method (usually `retrieve`) exposed on the client. It calls `build_request_and_run(RequestStructClass, ResponseStructClass, **params)`.
2. **Request struct** (`lib/steam_api_client/structs/requests/get_*.rb`) — a Dry::Struct describing the HTTP call. Subclasses either:
   - `Requests::Abstract` for the Web API: must define `interface`, `path`, `version` (each with a trailing `/`, e.g. `"ISteamUser/"`, `"GetPlayerSummaries/"`, `"v0002/"`), or
   - `Requests::StorefrontAbstract` for the Storefront API: defines only `path`; default `query_params` includes `cc`/`l`.
   Each also defines `self.build_from_params(params)` (validates required keys, raises `StandardError` if missing), `query_params`, and usually overrides `body` to `{}` and `needs_authorization?` (adds `key=<api_token>` to the query when true). `endpoint_kind` (`:base_endpoint` / `:storefront_endpoint`) selects the URL builder in `Request`.
3. **Response struct** (`lib/steam_api_client/structs/*.rb`, subclass of `Structs::Base`) — a Dry::Struct mirroring the JSON payload; `build_from_response(hash)` defaults to `new(**hash)` but can be overridden to reshape the payload (e.g. `AppDetails::Details` unwraps the app-id-keyed top level). Use `attribute?` for fields Steam may omit; shared types live in `Structs::Types` (incl. `Types::Optional::String/Integer`).

Pipeline: `Requestor` → `RequestStruct.build_from_params` → `SteamApiClient::Request` (builds URL with `URI.join` and a `Typhoeus::Request`) → `#run` → `SteamApiClient::Response` (wraps Typhoeus response; `#result` parses JSON with symbolized keys into the response struct, raising `Errors::ResponseParseError` with the JSON/Dry::Struct error as `cause` when that fails) → `FailureHandler.instance.call` raises `SteamApiClient::Errors::*` subclasses of `ApiError` by status code / timeout.

### Adding a new endpoint

- Create the request struct, response struct, and requestor (plus specs mirroring the `lib/` path under `spec/`).
- **Register every new file manually in `lib/steam_api_client.rb`** — there is no autoloading, and require order matters (nested struct classes such as `PlayerSummary` or `AppDetails::*` must be required before the structs that reference them).
- Add an `attr_reader` and instantiate the requestor in `SteamApiClient::Client#initialize`.

### Gotchas

- `Client.new` takes a keyword arg: `SteamApiClient::Client.new(api_token: "...")` (the README's positional example is outdated).
- `Client#api_token` returns the instance token, falling back to the class-level `Client.configure` value. Specs that call `configure` must reset it (`after { described_class.config.api_token = nil }`) because the setting is global.
- ActiveSupport is not a dependency — don't use `as_json`, `deep_symbolize_keys`, etc. `Dry::Struct#to_h` already returns a recursively symbolized hash.
- SimpleCov loads stdlib gems (e.g. `json`) during specs, which can mask missing requires in `lib/steam_api_client.rb`. Check with `bundle exec ruby -Ilib -e 'require "steam_api_client"; ...'` outside RSpec.
