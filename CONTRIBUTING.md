# Contributing

Thanks for helping with `steam_api_client`! Bug reports, endpoint requests and pull requests are
welcome. Everyone taking part is expected to follow the [Code of Conduct](CODE_OF_CONDUCT.md).

Found a security problem? Don't open an issue: see [SECURITY.md](SECURITY.md).

## Start with an issue

Every change starts with an issue, so the reason for it is written down before the code. Pick one
from the [issue tracker](https://github.com/jpechaves/steam_api/issues) or open a new one (bug
report, feature request or endpoint request). Pull requests reference it with `Closes #N`.

## Setup

```bash
bin/setup     # bundle install
bin/console   # IRB with the gem loaded
```

Ruby 3.3 or newer. CI runs the specs on Ruby 3.3, 3.4 and 4.0.

## Checks

Run these before opening a pull request. CI runs all of them:

```bash
bin/rspec                                       # specs, with SimpleCov
bin/lint                                        # Standard Ruby (bin/standardrb --fix autofixes)
bundle exec rubycritic lib --no-browser         # code quality score (CI has a minimum score)
bundle exec bundler-audit check --update        # known advisories in Gemfile.lock
bin/check_changelog origin/main                 # the CHANGELOG check below
```

CI fails below **98% line / 95% branch** coverage of `lib/`.

## Tests

- Write the spec first, see it fail, then make it pass.
- Specs never hit the network: `WebMock.disable_net_connect!` is on, and requests are stubbed
  with `stub_request` using the exact URL.
- Real Steam responses can be added to `spec/fixtures/steam/`, but **only anonymized** (see
  [its README](spec/fixtures/steam/README.md)). Never commit an API key, a real SteamID other
  than Steam's documented example, or anyone's profile data.

## CHANGELOG

User-visible changes (anything under `lib/` or the gemspec) add a line under `## [Unreleased]` in
[CHANGELOG.md](CHANGELOG.md), in the right group (Added / Changed / Fixed / Security) and with
the issue number. The `changelog` check enforces it. Changes to CI, `bin/` or specs only need no
entry: label the pull request `skip-changelog`.

Pull requests never bump the version.

## Releases (maintainer)

A release is its own issue and pull request:

1. `bin/bump patch|minor|major` on a release branch: bumps `version.rb` and `Gemfile.lock`, and
   moves `[Unreleased]` under the new version.
2. Merge the release pull request.
3. `bin/release` from an up-to-date `main`: publishes the gem (MFA) and pushes the `v<version>` tag.
   It refuses to run while `[Unreleased]` has entries: those changes aren't part of the version.
