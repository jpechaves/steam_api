# Using steam_api_client

- [Configuration](#configuration)
- [Calling an endpoint](#calling-an-endpoint)
- [Endpoints](#endpoints)
  - [Players](#players): [`player_summaries`](#player_summaries), [`player_steamid`](#player_steamid), [`player_friends`](#player_friends), [`player_level`](#player_level), [`player_owned_games`](#player_owned_games), [`player_recent_games`](#player_recent_games), [`player_achievements`](#player_achievements), [`player_game_stats`](#player_game_stats)
  - [Apps](#apps): [`app_details`](#app_details), [`app_news`](#app_news), [`app_global_achievements`](#app_global_achievements), [`game_current_players`](#game_current_players)
- [Results](#results)
- [Errors](#errors)
- [Limits and caveats](#limits-and-caveats)

The values in the examples are real-shaped, but illustrative: Steam's data changes all the time.

## Configuration

Most endpoints need a [Steam Web API key](https://steamcommunity.com/dev/apikey). Set it once for every client, or per client:

```ruby
SteamApiClient::Client.configure do |config|
  config.api_token = ENV.fetch("STEAM_API_KEY")
end

client = SteamApiClient::Client.new                                   # uses the configured key
client = SteamApiClient::Client.new(api_token: "another-key")         # overrides it
```

Calling an endpoint that needs a key without one raises `SteamApiClient::Errors::MissingApiToken` before anything is sent.

| Setting | Default | Meaning |
|---|---|---|
| `api_token` | `nil` | Steam Web API key |
| `timeout` | `10` | Seconds for the whole request |
| `connect_timeout` | `5` | Seconds to open the connection |
| `adapter` | `:net_http` | [Faraday adapter](https://lostisland.github.io/faraday/#/adapters/index); add its gem to your Gemfile |
| `connection { \|faraday\| ... }` | none | Customizes the Faraday connection (middleware, adapter options) |

Every setting can be given globally (`Client.configure`) or per client (`Client.new(timeout: 3)`, or a block for the connection). Per-client values win. `Client.reset_config!` restores the defaults, which is handy in specs.

```ruby
SteamApiClient::Client.configure do |config|
  config.timeout = 30
  config.connect_timeout = 2
  config.adapter = :net_http_persistent # from the net-http-persistent adapter gem
  config.connection { |faraday| faraday.request :instrumentation }
end

# The connection block runs after the adapter is set, so it can also replace it, with options
client = SteamApiClient::Client.new do |faraday|
  faraday.adapter :net_http_persistent, pool_size: 5
end
```

> **Logging:** Steam only accepts the key in the query string, so a logger that prints request URLs prints your key. The gem keeps it out of its own `inspect` output (`api_token=[REDACTED]`), but a logging middleware needs a filter:
>
> ```ruby
> client = SteamApiClient::Client.new do |faraday|
>   faraday.response :logger, Rails.logger, headers: false do |logger|
>     logger.filter(/(key=)[^&\s]+/, '\1[REDACTED]')
>   end
> end
> ```

In your own specs, Faraday's test adapter replaces the network:

```ruby
stubs = Faraday::Adapter::Test::Stubs.new do |stub|
  stub.get("/IPlayerService/GetSteamLevel/v0001/") { [200, {}, '{"response":{"player_level":10}}'] }
end
client = SteamApiClient::Client.new(api_token: "test") { |faraday| faraday.adapter :test, stubs }
client.player_level.retrieve(steamid: 76561197960435530) # => 10
```

## Calling an endpoint

Every endpoint is a method on the client with a `retrieve` method that takes keyword arguments:

```ruby
client.player_level.retrieve(steamid: 76561197960435530) # => 32
```

- Missing or unknown arguments raise `ArgumentError` with Ruby's own messages (`missing keyword: :steamid`, `unknown keyword: :steam_id`).
- Values are checked: IDs must be Integers (numeric strings like `"76561197960435530"` are accepted), lists must be Arrays. Anything else raises `ArgumentError`, e.g. `steamid must be an Integer, got "robin"`.
- `retrieve_raw` takes the same arguments and returns Steam's JSON untouched (with symbol keys), for fields the gem doesn't expose:

  ```ruby
  client.player_level.retrieve_raw(steamid: 76561197960435530) # => {response: {player_level: 32}}
  ```

## Endpoints

A 🔑 means the endpoint needs an API key.

### Players

#### `player_summaries`

🔑 Profiles of up to 100 players. Steam leaves out IDs it doesn't know.

```ruby
players = client.player_summaries.retrieve(steamids: [76561197960435530, 76561197960287930])
# => [#<data SteamApiClient::PlayerSummary steam_id=76561197960435530, persona_name="Robin", ...>, ...]

player = players.first
player.persona_name               # => "Robin"
player.profile_url                # => "https://steamcommunity.com/id/robinwalker/"
player.avatar_full                # => "https://avatars.steamstatic.com/..._full.jpg"
player.persona_state              # => 0 (0 offline, 1 online, 2 busy, 3 away, 4 snooze, 5 looking to trade, 6 looking to play)
player.community_visibility_state # => 3 (3 public, 1 not visible to you)
player.country_code               # => "US", or nil when not public
```

`SteamApiClient::PlayerSummary` fields: `steam_id`, `persona_name`, `profile_url`, `avatar`, `avatar_medium`, `avatar_full`, `avatar_hash`, `persona_state`, `persona_state_flags`, `community_visibility_state`, `profile_state`, `last_logoff`, `comment_permission`, `real_name`, `time_created`, `country_code`, `primary_clan_id`. Everything after `community_visibility_state` is `nil` when the profile (or that part of it) isn't public. Times are unix timestamps.

#### `player_steamid`

🔑 The 64 bit SteamID a vanity URL (`steamcommunity.com/id/<vanityurl>`) resolves to, or `nil`.

```ruby
client.player_steamid.retrieve(vanityurl: "robinwalker")     # => 76561197960435530
client.player_steamid.retrieve(vanityurl: "no-such-profile") # => nil
```

#### `player_friends`

🔑 A player's friend list. `relationship:` is `"all"` (default) or `"friend"`.

```ruby
client.player_friends.retrieve(steamid: 76561197960435530)
# => [#<data SteamApiClient::Friend steam_id=76561198000000002, relationship="friend", friend_since=1262304000>, ...]
```

A private friend list raises `Errors::HttpUnauthorized`.

#### `player_level`

🔑 A player's Steam level, or `nil` when the profile isn't visible.

```ruby
client.player_level.retrieve(steamid: 76561197960435530) # => 32
```

#### `player_owned_games`

🔑 The games a player owns, or `nil` when the library isn't public. `include_appinfo: true` adds each game's name and icon, `include_played_free_games: true` adds free games the player has played (both default to `false`).

```ruby
library = client.player_owned_games.retrieve(steamid: 76561198000000001, include_appinfo: true)
# => #<data SteamApiClient::OwnedGames game_count=375, games=[...]>

library.games.first
# => #<data SteamApiClient::Game app_id=440, name="Team Fortress 2", img_icon_url="f568912870a4684f9ec76277a1a404dda6bab213",
#     playtime_forever=2090, playtime_2weeks=nil, has_community_visible_stats=true, has_leaderboards=true, ...>

library.games.sum(&:playtime_forever) / 60 # hours played
```

`SteamApiClient::Game` fields: `app_id`, `name`, `img_icon_url`, `playtime_forever`, `playtime_2weeks`, `has_community_visible_stats`, `has_leaderboards`, `content_descriptor_ids`, `playtime_windows_forever`, `playtime_mac_forever`, `playtime_linux_forever`, `rtime_last_played`. Playtimes are in minutes. `playtime_2weeks` is only sent for games played recently, and Steam no longer sends the per-platform playtimes or `rtime_last_played` for most libraries.

#### `player_recent_games`

🔑 The games played in the last two weeks, or `nil` when not public. `count:` defaults to 5.

```ruby
recent = client.player_recent_games.retrieve(steamid: 76561198000000001, count: 3)
# => #<data SteamApiClient::RecentGames total_count=1, games=[#<data SteamApiClient::Game app_id=2868840, name="Slay the Spire 2", playtime_2weeks=922, ...>]>
```

#### `player_achievements`

🔑 A player's achievements in a game.

```ruby
stats = client.player_achievements.retrieve(appid: 440, steamid: 76561198000000001)
stats.game_name # => "Team Fortress 2"
stats.achievements.first
# => #<data SteamApiClient::PlayerAchievements::Achievement api_name="TF_PLAY_GAME_EVERYCLASS", achieved=true, unlock_time=1262304000>
stats.achievements.count(&:achieved) # => 95
```

`unlock_time` is a unix timestamp, `0` when locked. A private profile raises `Errors::HttpForbidden` (`Profile is not public`), and a game without stats `Errors::HttpBadRequest` (`Requested app has no stats`).

#### `player_game_stats`

🔑 A player's stats and unlocked achievements in a game.

```ruby
stats = client.player_game_stats.retrieve(appid: 440, steamid: 76561198000000001)
stats.stats.first        # => #<data SteamApiClient::PlayerGameStats::Stat name="Scout.accum.iDamageDealt", value=26580>
stats.achievements.first # => #<data SteamApiClient::PlayerGameStats::Achievement name="TF_PLAY_GAME_EVERYCLASS", achieved=true>
```

Stat values are Integers or Floats, as the game defines them. A private profile, or a game without stats, raises `Errors::HttpBadRequest`.

#### `player_wishlist`

The apps on a player's wishlist. No key needed.

```ruby
client.player_wishlist.retrieve(steamid: 76561198000000001).first
# => #<data SteamApiClient::WishlistItem app_id=202350, priority=3, date_added=1403384867>
```

`priority` is the player's ranking of the app, and `date_added` a unix timestamp. A private or empty wishlist is `[]`. An ID that isn't a valid SteamID (e.g. `1`) raises `Errors::HttpBadRequest`, here and in the two endpoints below.

#### `player_wishlist_count`

The number of apps on a player's wishlist, or `nil` when it's private or empty. No key needed.

```ruby
client.player_wishlist_count.retrieve(steamid: 76561198000000001) # => 19
```

#### `player_followed_games`

The app IDs a player follows in the store, or `[]` when the profile is private. No key needed.

```ruby
client.player_followed_games.retrieve(steamid: 76561198000000001) # => [400, 440, 620, ...]
```

### Apps

#### `app_details`

The store page of an app, from Steam's unofficial [Storefront API](https://wiki.teamfortress.com/wiki/User:RJackson/StorefrontAPI), or `nil` when the app is unavailable (unknown, removed, or not sold in that country). No key needed.

- `filters:` limits the fields, e.g. `["basic", "price_overview", "platforms"]`. Every field when empty (default). Fields left out are `nil`.
- `country_code:` (default `"US"`) sets the currency and the availability. `locale:` (default `"en"`) the language of the texts, e.g. `"portuguese"`.

```ruby
app = client.app_details.retrieve(appid: 1091500, filters: ["basic", "price_overview"], country_code: "BR", locale: "portuguese")
app.name            # => "Cyberpunk 2077"
app.price_overview  # => #<data SteamApiClient::AppDetails::Price currency="BRL", initial=19990, final=5997, discount_percent=70,
                    #     initial_formatted="R$ 199,90", final_formatted="R$ 59,97">
client.app_details.retrieve(appid: 440).platforms
# => #<data SteamApiClient::AppDetails::Platforms windows=true, mac=false, linux=true>
```

`SteamApiClient::AppDetails` fields: `app_id`, `type`, `name`, `required_age`, `is_free`, `dlc`, `detailed_description`, `about_the_game`, `short_description`, `supported_languages`, `header_image`, `website`, `pc_requirements` / `mac_requirements` / `linux_requirements` (`AppDetails::Requirements`: `minimum`, `recommended`, as HTML), `developers`, `publishers`, `price_overview` (`AppDetails::Price`, in cents; `nil` for free apps), `packages`, `package_groups` (`AppDetails::PackageGroup` with `subs`: `AppDetails::Package`), `platforms`, `metacritic` (`score`, `url`), `categories` and `genres` (`id`, `description`), `screenshots`, `movies` (`AppDetails::Movie` with DASH and HLS streams), `recommendations` (the number of user reviews), `achievements` (`total`, `highlighted`), `release_date` (`coming_soon`, `date`), `support_info` (`url`, `email`), `background`, `background_raw`, `content_descriptors` (`ids`, `notes`).

#### `package_details`

A package (a bundle, or a "sub" such as an edition or a license) in the store, or `nil` when it's unavailable. Storefront API, no key needed. Takes one `packageid:` (Steam rejects several at once), and `country_code:` / `locale:` like `app_details`. Package IDs are in `app_details`' `packages` and `package_groups`.

```ruby
package = client.package_details.retrieve(packageid: 469)
package.name   # => "The Orange Box"
package.apps   # => [#<data SteamApiClient::PackageDetails::App id=220, name="Half-Life 2">, ...]
package.price  # => #<data SteamApiClient::PackageDetails::Price currency="USD", initial=1999, final=1999, discount_percent=0, individual=1998>
```

`SteamApiClient::PackageDetails` fields: `package_id`, `name`, `page_content` (HTML), `purchase_text`, `page_image`, `header_image`, `small_logo`, `apps` (`id`, `name`), `price` (in cents; `individual` is what the apps cost on their own; `nil` for free packages), `platforms` and `release_date` (as in `AppDetails`), `controller` (`full_gamepad`). An invalid ID such as `0` raises `Errors::HttpBadRequest`.

#### `app_dlc`

An app's DLC, or `nil` when the app is unknown. Storefront API, no key needed. Takes `appid:`, `country_code:` and `locale:`.

```ruby
result = client.app_dlc.retrieve(appid: 292030)
result.name # => "The Witcher 3: Wild Hunt — Remastered"
result.dlc.last
# => #<data SteamApiClient::AppDlc::Dlc id=1229320, name="The Witcher 3: Wild Hunt — Remastered Soundtrack", header_image="https://...",
#     price_overview=#<data SteamApiClient::AppDlc::Price currency="USD", initial=1099, final=1099, discount_percent=0>,
#     platforms=#<data SteamApiClient::AppDetails::Platforms windows=true, mac=true, linux=true>,
#     release_date=#<data SteamApiClient::AppDlc::ReleaseDates steam=1581374766, mac=1581374752, linux=1581374752>, controller_support="full">
```

`price_overview` is `nil` for free DLC and DLC not sold on its own. `release_date` has a unix time per platform (`steam`, `mac`, `linux`), each `nil` when Steam doesn't know it. Steam sometimes adds milliseconds, and the time is then a Float.

#### `store_search`

Apps in the store matching a search term, at most 10 (Steam's limit, with no paging). Storefront API, no key needed. Takes `term:`, `country_code:` and `locale:`.

```ruby
client.store_search.retrieve(term: "portal").first
# => #<data SteamApiClient::StoreSearchResult id=620, type="app", name="Portal 2",
#     price=#<data SteamApiClient::StoreSearchResult::Price currency="USD", initial=999, final=999>, tiny_image="https://...",
#     metascore=95, platforms=#<data SteamApiClient::AppDetails::Platforms windows=true, mac=false, linux=true>,
#     streaming_video=false, controller_support="full">
```

`price` is `nil` for free apps, `metascore` when the app has no Metacritic score. No match is `[]`.

#### `app_news`

The latest news of an app. `count:` is required, `maxlength:` (default 300) shortens each item's contents.

```ruby
client.app_news.retrieve(appid: 440, count: 5).first
# => #<data SteamApiClient::NewsItem gid="...", title="Team Fortress 2 Update Released", url="https://steamstore-a.akamaihd.net/news/externalpost/...",
#     is_external_url=true, author="erics", contents="...", feed_label="Community Announcements", date=1792179520,
#     feed_name="steam_community_announcements", feed_type=1, app_id=440, tags=["patchnotes"]>
```

#### `app_global_achievements`

The share of players who unlocked each achievement of an app, in percent.

```ruby
client.app_global_achievements.retrieve(appid: 440).first
# => #<data SteamApiClient::GlobalAchievement name="TF_SCOUT_LONG_DISTANCE_RUNNER", percent=49.5>
```

#### `game_current_players`

The number of players in a game right now.

```ruby
client.game_current_players.retrieve(appid: 440) # => 88231
```

An unknown app raises `Errors::HttpNotFound`.

## Results

Results are immutable [`Data`](https://docs.ruby-lang.org/en/3.3/Data.html) objects, Integers, or Arrays of them:

- They compare by value, are frozen, and work with pattern matching:

  ```ruby
  case client.player_summaries.retrieve(steamids: [id]).first
  in {community_visibility_state: 3, persona_name:} then "#{persona_name} has a public profile"
  in nil then "no such player"
  else "private profile"
  end
  ```

- `#to_h` returns a plain Hash, nested parts included (e.g. to serialize as JSON).
- Lists Steam leaves out are `[]`. Data that isn't visible (private profiles, unavailable apps, unmatched vanity URLs) is `nil`.

## Errors

```
StandardError
├── SteamApiClient::Errors::ApiError                 # Steam answered with an HTTP error
│   ├── HttpBadRequest            (400)
│   ├── HttpUnauthorized          (401)
│   ├── HttpForbidden             (403)
│   ├── HttpNotFound              (404)
│   ├── HttpTimeout               (408, or no answer within the timeouts)
│   ├── HttpTooManyRequests       (429)  #retry_after
│   ├── HttpInternalServerError   (500)
│   ├── HttpBadGateway            (502)
│   └── HttpServiceUnavailable    (503)  #retry_after
├── SteamApiClient::Errors::ConnectionError          # Steam couldn't be reached: DNS, refused connection, TLS
├── SteamApiClient::Errors::ResponseParseError       # the body isn't the JSON the endpoint returns
└── SteamApiClient::Errors::MissingApiToken          # the endpoint needs a key and the client has none
ArgumentError                                        # missing, unknown or invalid arguments
```

- Other HTTP error statuses raise a plain `ApiError`. Its message has the status code and Steam's body.
- `ConnectionError` is **not** an `ApiError`, and has the adapter's error as `#cause`. A timed-out request is an `HttpTimeout` without a response.
- `ResponseParseError#response` is the response, and `#cause` the JSON error or the `SteamApiClient::Model::Error` naming the field that didn't match.
- None of the messages contain the API key.

To rescue everything that comes from Steam or the network:

```ruby
rescue SteamApiClient::Errors::ApiError, SteamApiClient::Errors::ConnectionError, SteamApiClient::Errors::ResponseParseError
```

### Retrying

`HttpTooManyRequests` and `HttpServiceUnavailable` expose `#retry_after`, the seconds from Steam's `Retry-After` header (`nil` when it sends none). For example:

```ruby
RETRYABLE = [
  SteamApiClient::Errors::HttpTooManyRequests, SteamApiClient::Errors::HttpBadGateway,
  SteamApiClient::Errors::HttpServiceUnavailable, SteamApiClient::Errors::HttpTimeout
].freeze

def with_retries(attempts: 3)
  tries = 0
  begin
    yield
  rescue *RETRYABLE => error
    tries += 1
    raise if tries >= attempts

    sleep((error.respond_to?(:retry_after) && error.retry_after) || 2**tries)
    retry
  end
end

with_retries { client.game_current_players.retrieve(appid: 440) }
```

Don't retry other 4xx errors: they won't succeed on their own.

## Limits and caveats

- **Rate limits.** Steam's [Web API terms](https://steamcommunity.com/dev/apiterms) allow 100,000 calls per day per key. The Storefront API (`app_details`, `package_details`, `app_dlc`, `store_search`) is rate limited per IP address, commonly reported at about 200 requests per 5 minutes. Both answer `429` when you go over. Cache what you can.
- **The Storefront API is unofficial.** The Storefront endpoints use the API behind Steam's store and Big Picture mode. Valve doesn't document it, and its fields change without notice.
- **Private profiles.** What a player hides depends on their privacy settings. Depending on the endpoint, Steam answers with an error (`player_achievements`: 403, `player_game_stats`: 400, `player_friends`: 401) or with empty data, which the gem returns as `nil` or `[]` (`player_owned_games`, `player_recent_games`, `player_level`, `player_wishlist`, `player_wishlist_count`, `player_followed_games`). Steam answers the same way for an empty wishlist, so the wishlist endpoints can't tell the two apart. `player_summaries` still returns the public part of the profile.
- **The key is in the URL.** Steam requires `?key=...` in the query string. Treat logs of request URLs as secrets (see [Configuration](#configuration)), and [rotate your key](https://steamcommunity.com/dev/apikey) if it leaks.
- **SteamIDs are 64 bit Integers** (e.g. `76561197960435530`). Use `player_steamid` to get one from a vanity URL.
