# Steam API fixtures

Real responses from the Steam Web API, recorded with an API key and used by the specs in
`spec/steam_api_client/fixtures/` (through `SteamFixtures#parse_steam_fixture`).

They are **anonymized and trimmed** before being committed:

- Every SteamID is replaced by a fake one (`7656119800000000N`), except `76561197960435530`
  (Robin Walker, the example profile in Steam's own documentation).
- Names, real names, avatars, profile URLs, country and clan IDs are replaced by placeholders.
- Long lists (friends, games, achievements, stats) are cut down to a few entries, keeping at
  least one entry for every field variant Steam sent.
- `*_private.json` files are the responses for a private profile, kept as received.

The API key is never part of a response, and fixtures must not contain it.
