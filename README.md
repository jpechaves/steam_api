# Summary
- [Summary](#summary)
- [steam\_api\_client](#steam_api_client)
  - [Features](#features)
  - [Installation](#installation)
  - [Usage](#usage)
  - [Development](#development)
    - [Requirements](#requirements)
    - [Initial Setup](#initial-setup)
    - [Running the Interactive Console](#running-the-interactive-console)
    - [Running Tests](#running-tests)
    - [Code Quality](#code-quality)
    - [Releasing](#releasing)
  - [Contributing](#contributing)
    - [How to Contribute](#how-to-contribute)
  - [License](#license)
  - [Code of Conduct](#code-of-conduct)

# steam_api_client

[![Gem Version](https://img.shields.io/gem/v/steam_api_client)](https://rubygems.org/gems/steam_api_client)
[![CI](https://github.com/jpechaves/steam_api/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/jpechaves/steam_api/actions/workflows/ci.yml)

> Previously developed as `steam_api`. It is not related to the [`steam_api`](https://rubygems.org/gems/steam_api) gem on RubyGems.

A Ruby gem for interacting with the [Steam Web API](https://developer.valvesoftware.com/wiki/Steam_Web_API). It returns plain Ruby objects (`Data`) with snake_case fields, such as game details, player information, and achievements, and its only dependency is Faraday.

## Features

- Fetch game details, news, and global achievements.
- Retrieve player summaries, friends, achievements, and game stats.
- Get owned games, recently played games, and Steam levels.
- Supports both authenticated and unauthenticated requests.
- Easy-to-use client configuration.

## Installation

Add the gem to your application's Gemfile:

```ruby
gem "steam_api_client"
```

and run `bundle install`. Or let Bundler do both:

```bash
$ bundle add steam_api_client
```

Without Bundler, install it with:

```bash
$ gem install steam_api_client
```

and load it with:

```ruby
require "steam_api_client"
```

## Usage

```ruby
SteamApiClient::Client.configure do |config|
  config.api_token = ENV.fetch("STEAM_API_KEY") # https://steamcommunity.com/dev/apikey
end

client = SteamApiClient::Client.new

player = client.player_summaries.retrieve(steamids: [76561197960435530]).first
player.persona_name # => "Robin"

client.player_level.retrieve(steamid: player.steam_id)                  # => 32
client.player_owned_games.retrieve(steamid: player.steam_id)            # => OwnedGames, or nil when private
client.app_details.retrieve(appid: 440, filters: ["basic"]).name        # => "Team Fortress 2"
client.game_current_players.retrieve(appid: 440)                        # => 88231
```

Results are immutable `Data` objects with snake_case fields (or Integers, or Arrays of them). HTTP errors raise `SteamApiClient::Errors::*` classes, e.g. `HttpTooManyRequests` with `#retry_after`.

**See [docs/USAGE.md](docs/USAGE.md)** for every endpoint and what it returns, configuration (timeouts, adapter, Faraday middleware, logging without leaking the key), errors and retries, and Steam's limits.

## Development

### Requirements

- Ruby >= 3.3

### Initial Setup

Run the following command to set up the gem using Bundler:

```bash
$ bin/setup
```

### Running the Interactive Console

Launch an interactive Ruby session:

```bash
$ bin/console
```

### Running Tests

Execute all automated tests:

```bash
$ bin/rspec
```

### Code Quality

We use [standardrb](https://github.com/standardrb/standard) for linting and code quality checks. To analyze the code, run:

```bash
$ bin/lint
```

### Releasing

Each pull request with a user-visible change adds a line under `## [Unreleased]` in `CHANGELOG.md`. Pull requests don't change the version.

To release the merged changes, open a release pull request:

```bash
$ git checkout -b release/0.10.0
$ bin/bump minor         # or patch / major: bumps version.rb and Gemfile.lock, moves [Unreleased] under "## [0.10.0] - <today>"
```

Commit, open the pull request, and merge it. Then publish from `main`:

```bash
$ bin/release            # build and push the gem (asks for your RubyGems MFA code), then tag v<version> and push the tag
$ bin/release --dry-run  # show what would happen without building, pushing or tagging
```

`bin/release` checks out and pulls `main` first, and refuses to run with uncommitted changes or without a CHANGELOG entry. Steps that are already done are skipped, so running it again for a released version does nothing.

## Contributing

Bug reports and pull requests are welcome on GitHub at [GitHub Repository](https://github.com/jpechaves/steam_api). This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Code of Conduct](https://github.com/jpechaves/steam_api/blob/main/CODE_OF_CONDUCT.md).

### How to Contribute

1. Fork the repository.
2. Create a new branch for your feature or bug fix.
3. Write tests for your changes.
4. Run the tests to ensure everything works.
5. Submit a pull request.

## License

This gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Steam project's codebases, issue trackers, chat rooms, and mailing lists is expected to follow the [Code of Conduct](https://github.com/jpechaves/steam_api/blob/main/CODE_OF_CONDUCT.md).
