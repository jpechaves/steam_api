# Summary
- [Summary](#summary)
- [steam\_api\_client](#steam_api_client)
  - [Features](#features)
  - [Installation](#installation)
  - [Usage](#usage)
    - [Configuring the Client](#configuring-the-client)
    - [Example Requests](#example-requests)
      - [Get Player Summaries](#get-player-summaries)
      - [Get App Details](#get-app-details)
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

A Ruby gem for interacting with the [Steam Web API](https://developer.valvesoftware.com/wiki/Steam_Web_API). This gem provides a structured and user-friendly way to fetch various types of data from Steam's API endpoints, such as game details, player information, and achievements.

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

### Configuring the Client

```ruby
SteamApiClient::Client.configure do |config|
  config.api_token = "your-API-token-value"
end
```

Alternatively, you can initialize the client directly:

```ruby
client = SteamApiClient::Client.new(api_token: "your-API-token-value")
```

Requests time out after 10 seconds (5 seconds to connect) and raise `SteamApiClient::Errors::HttpTimeout`. You can change this globally or per client, in seconds:

```ruby
SteamApiClient::Client.configure do |config|
  config.timeout = 30
  config.connect_timeout = 2
end

client = SteamApiClient::Client.new(api_token: "your-API-token-value", timeout: 5)
```

If Steam can't be reached at all (DNS failure, refused connection, TLS error), requests raise `SteamApiClient::Errors::ConnectionError` instead.

Requests go through [Faraday](https://github.com/lostisland/faraday) with its default `Net::HTTP` adapter. To use another one, add its gem to your Gemfile and set it globally or per client:

```ruby
SteamApiClient::Client.configure do |config|
  config.adapter = :httpx # from the httpx gem
end

client = SteamApiClient::Client.new(api_token: "your-API-token-value", adapter: :net_http)
```

### Example Requests

#### Get Player Summaries

```ruby
client = SteamApiClient::Client.new(api_token: "your-API-token-value")
client.player_summaries.retrieve(steamids: [76561198160009756])
```

#### Get App Details

```ruby
client = SteamApiClient::Client.new
client.app_details.retrieve(appid: 1091500, filters: ["basic"])
```

For more examples, see the [Usage](#usage) section above.

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

Bug reports, endpoint requests and pull requests are welcome on [GitHub](https://github.com/jpechaves/steam_api). Every change starts with an issue; see [CONTRIBUTING.md](CONTRIBUTING.md) for the setup, the checks and the CHANGELOG rules. Security problems go through [SECURITY.md](SECURITY.md), not public issues.

This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Code of Conduct](CODE_OF_CONDUCT.md).

## License

This gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Steam project's codebases, issue trackers, chat rooms, and mailing lists is expected to follow the [Code of Conduct](https://github.com/jpechaves/steam_api/blob/main/CODE_OF_CONDUCT.md).
