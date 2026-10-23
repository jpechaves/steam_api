# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- `Client` `adapter` setting (`Client.configure { |c| c.adapter = ... }` or `Client.new(adapter:)`) to choose the Faraday adapter, `:net_http` by default (#35).

### Changed

- **Breaking:** the HTTP client is now [Faraday](https://github.com/lostisland/faraday) with its `Net::HTTP` adapter, replacing Typhoeus (#35). The gem no longer installs `typhoeus`, `ethon` or `ffi` (a compiled gem that needs libcurl). The public API (`Client`, every `retrieve`, the `Errors::*` classes) is unchanged, except:
  - Connection failures (DNS, refused connection, TLS) raise the new `SteamApiClient::Errors::ConnectionError`. It is **not** an `ApiError`: before, they surfaced as a generic `ApiError` with status code `0`.
  - `HttpTimeout` for a timed-out request has no HTTP response (`#response` is `nil`), and its message gives the timeouts. A real `408` response also raises `HttpTimeout`.
  - Redirects aren't followed anymore. No Steam endpoint redirects (all were checked).

## [0.10.0] - 2026-10-23

### Added

- `player_game_stats` exposes the game's stats: `playerstats.stats`, a list of `name`/`value` pairs. Values keep the Integer or Float Steam sends (#71).
- `PlayerSummary` exposes `realname`, `timecreated`, `loccountrycode`, `avatarhash`, `primaryclanid` (an Integer, like other SteamIDs) and `personastateflags`. They're `nil` when the profile doesn't make them public (#71).
- `SteamApiClient::Errors::HttpTooManyRequests` (429), `HttpBadGateway` (502) and `HttpServiceUnavailable` (503), so rate limits and outages can be retried selectively. 429 and 503 errors expose `#retry_after`, the seconds from the `Retry-After` header (`nil` when absent). All three are `ApiError`s, like before (#27).
- `SteamApiClient::Errors::MissingApiToken`, raised before any request when an endpoint needs an API token and the client has none (nil or empty). Previously the request was sent and Steam's HTML "key is missing" page came back as `HttpBadRequest` (#25).

### Changed

- Every response struct, including the nested element structs (`PlayerSummary`, `AppNew`, friends, games and achievements), inherits from `SteamApiClient::Structs::Base`, so they all accept string keys and respond to `build_from_response` (#28).
- GET requests (every endpoint) no longer send an empty JSON body (`"{}"`) and `Content-Type: application/json` (#26).
- Missing or invalid request parameters raise `ArgumentError` instead of a bare `StandardError` (#25). `ArgumentError` is a `StandardError`, so existing `rescue StandardError` code keeps working.
- **Breaking:** every `retrieve` method takes keyword arguments (#24), so IDs can't be swapped by position. Defaults are unchanged.

  | Before | After |
  |---|---|
  | `player_summaries.retrieve([id])` | `player_summaries.retrieve(steamids: [id])` |
  | `player_steamid.retrieve("name")` | `player_steamid.retrieve(vanityurl: "name")` |
  | `player_friends.retrieve(id, "friend")` | `player_friends.retrieve(steamid: id, relationship: "friend")` |
  | `player_level.retrieve(id)` | `player_level.retrieve(steamid: id)` |
  | `player_owned_games.retrieve(id, include_appinfo: true)` | `player_owned_games.retrieve(steamid: id, include_appinfo: true)` |
  | `player_recent_games.retrieve(id, 10)` | `player_recent_games.retrieve(steamid: id, count: 10)` |
  | `player_achievements.retrieve(appid, id)` | `player_achievements.retrieve(appid: appid, steamid: id)` |
  | `player_game_stats.retrieve(appid, id)` | `player_game_stats.retrieve(appid: appid, steamid: id)` |
  | `app_news.retrieve(appid, 5, 500)` | `app_news.retrieve(appid: appid, count: 5, maxlength: 500)` |
  | `app_global_achievements.retrieve(appid)` | `app_global_achievements.retrieve(appid: appid)` |
  | `game_current_players.retrieve(appid)` | `game_current_players.retrieve(appid: appid)` |

### Fixed

- `player_owned_games` failed on real public libraries: it required `playtime_windows_forever`, `playtime_mac_forever`, `playtime_linux_forever` and `rtime_last_played`, which Steam doesn't send. They're optional now, and `playtime_2weeks`, `has_community_visible_stats`, `has_leaderboards` and `content_descriptorids` are exposed (#70).
- Responses with duplicate JSON keys parse the same on every `json` gem version, with the last value winning. json 3 rejects duplicate keys by default, which would have raised `ResponseParseError` (#19).

### Changed

- Allows `dry-configurable` 1.2 and newer (`~> 1.1` instead of `~> 1.1.0`, which only allowed 1.1.x) (#19).
- **Breaking:** requires Ruby 3.3 or newer (#17). Ruby 3.0, 3.1 and 3.2 have reached end of life. CI now tests 3.3, 3.4 and 4.0.
- **Breaking:** response structs now validate their declared types (#15). Integer, Float and String fields convert Steam's values (Steam often sends numbers as strings), and a value that can't be converted raises `SteamApiClient::Errors::ResponseParseError` instead of passing through unchanged. `null` values still come through as `nil`.
  - `PlayerSummary#steamid` is now an Integer, like every other SteamID in the gem (it was a String).
  - `PlayerSummary#profilestate` is now an Integer (it was declared String; Steam sends `1`).
  - Global achievement `percent` is now a Float (it held Steam's raw value, e.g. `"49.6"`).
- The gem homepage and README links point to `github.com/jpechaves/steam_api` instead of the old `sosolidkk` account (#22).

## [0.9.1] - 2026-10-23

### Fixed

- The gem no longer packages development files (`CLAUDE.md`, `CODE_OF_CONDUCT.md`, `Gemfile`, `Gemfile.lock` and tooling dotfiles). It ships only `lib/`, `LICENSE`, `README.md` and `CHANGELOG.md` (#37).

## [0.9.0] - 2026-10-23

First release published to RubyGems, as [`steam_api_client`](https://rubygems.org/gems/steam_api_client).

### Changed

- **Breaking:** renamed the gem from `steam_api` to `steam_api_client`, since `steam_api` is taken on RubyGems by an unrelated gem (#21). Update your Gemfile to `gem "steam_api_client"`, use `require "steam_api_client"`, and replace the `SteamApi` namespace with `SteamApiClient` (e.g. `SteamApiClient::Client`, `SteamApiClient::Errors::HttpTimeout`).
- **Breaking:** `Response#result` raises `SteamApiClient::Errors::ResponseParseError` instead of letting `Dry::Struct::Error` escape when a response can't be built into its struct, and for bodies that aren't a JSON object (#11). The original error is available as `#cause`.
- `gem push` requires MFA (`rubygems_mfa_required`).
- Removed the `activesupport`, `vcr` and `webmock` dependencies.

### Added

- Configurable HTTP timeouts: 10s per request and 5s to connect by default. Set them with `Client.configure` (`timeout`, `connect_timeout`) or `Client.new(timeout:, connect_timeout:)`. Timed-out requests raise `HttpTimeout` (#12).
- `AppDetails::Movie` exposes Steam's streaming trailer manifests: `dash_av1`, `dash_h264`, `hls_h264` (#9).
- CI: Standard Ruby lint, a RubyCritic score gate, and bundler-audit on push, PRs and weekly (#31).

### Fixed

- `app_details` raised `Dry::Struct::Error` for every app with trailers, because Steam no longer returns `webm`/`mp4` (#9).
- `app_details` raised `Dry::Struct::Error` for unavailable apps. It now returns `response.success == false` with `response.data == nil` (#10).
- The token set through `Client.configure` was never sent. `Client#api_token` now falls back to it.
- `require "steam_api"` didn't load `json`, so requests failed outside the test suite.
- The default request `body` used ActiveSupport methods (`as_json`, `deep_symbolize_keys`) after ActiveSupport was removed.
- The README examples used a positional `Client.new` argument instead of `api_token:`.

### Security

- Bumped `concurrent-ruby` to 1.3.8 and `json` to 2.21.2 in `Gemfile.lock` to resolve bundler-audit advisories (#31). This affects development and CI only. Apps using the gem resolve their own versions.

## Earlier versions

The versions below were bumped in `version.rb` during development but **never published or tagged**. They are reconstructed from the git history (the gem was named `steam` until 0.1.5 and `steam_api` until 0.9.0).

## [0.8.0] - 2025-04-13

- Fixed YARD comments, added `bin/setup`, completed the struct specs and added the first request spec.
- Updated dependencies.

## [0.7.0] - 2024-07-27

- Removed unused development tooling and ran Standard Ruby on the whole project. There was no 0.6.0.

## [0.5.0] - 2024-06-03

- Raised the required Ruby version (needed by `dry-core`) and updated the CI Ruby versions.
- More specs.

## [0.4.0] - 2024-04-14

- Updated gem metadata. More struct specs.

## [0.3.0] - 2024-01-20

- Added a GitHub Actions workflow and dropped Ruby 2.6.
- Added specs for errors, responses and base structs. Removed unused code.

## [0.2.2] - 2023-06-28

- Added `EndpointKindNotSupported` for unknown endpoint kinds.
- Fixed query params not being sent with requests.
- Clearer parameter names. Updated gems and the Ruby version. First specs for the client and the failure handler.

## [0.2.1] - 2023-02-26

- Added support for the Storefront API and the app details endpoint.

## [0.1.5] - 2023-01-15

- Renamed the gem from `steam` to `steam_api`. There were no 0.1.3 or 0.1.4.

## [0.1.2] - 2022-11-25

- Client, structs, and request/response/error handling, with `HttpForbidden` (403) and `HttpInternalServerError` (500).
- Endpoints: player summaries, app news, global achievement percentages, player achievements, user game stats, recently played games, resolve vanity URL, current player count, player level, owned games and friend list.
- Development tooling configuration.

## [0.1.1] - 2022-09-29

- Basic client configuration.

## [0.1.0] - 2022-09-28

- Initial gem skeleton.

[Unreleased]: https://github.com/jpechaves/steam_api/compare/v0.10.0...HEAD
[0.10.0]: https://github.com/jpechaves/steam_api/compare/v0.9.1...v0.10.0
[0.9.1]: https://github.com/jpechaves/steam_api/compare/v0.9.0...v0.9.1
[0.9.0]: https://github.com/jpechaves/steam_api/releases/tag/v0.9.0
