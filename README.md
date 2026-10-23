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

### Example Requests

#### Get Player Summaries

```ruby
client = SteamApiClient::Client.new(api_token: "your-API-token-value")
client.player_summaries.retrieve([76561198160009756])
```

#### Get App Details

```ruby
client = SteamApiClient::Client.new
client.app_details.retrieve(appid: 1091500, filters: ["basic"])
```

For more examples, see the [Usage](#usage) section above.

## Development

### Requirements

- Ruby >= 3.0
- Docker (optional, for consistent development environments)

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

Bump `lib/steam_api_client/version.rb`, add a matching `## [<version>]` section to `CHANGELOG.md`, and merge to `main`. Then run:

```bash
$ bin/release            # build and push the gem (asks for your RubyGems MFA code), then tag v<version> and push the tag
$ bin/release --dry-run  # show what would happen without building, pushing or tagging
```

It checks out and pulls `main` first, and refuses to run with uncommitted changes or without a CHANGELOG entry. Steps that are already done are skipped, so running it again for a released version does nothing.

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
