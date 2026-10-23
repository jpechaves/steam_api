## [Unreleased]

### Changed

- **Breaking:** renamed the gem from `steam_api` to `steam_api_client`, since `steam_api` is taken on RubyGems by an unrelated gem (#21). Update your Gemfile to `gem "steam_api_client"`, use `require "steam_api_client"`, and replace the `SteamApi` namespace with `SteamApiClient` (e.g. `SteamApiClient::Client`, `SteamApiClient::Errors::HttpTimeout`).

## [0.1.0] - 2022-09-28

- Initial release
