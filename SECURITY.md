# Security policy

## Supported versions

Security fixes go into the latest minor release only. Please upgrade to it before reporting.

| Version | Supported |
|---|---|
| Latest minor release (see [RubyGems](https://rubygems.org/gems/steam_api_client)) | ✅ |
| Older releases | ❌ |

## Reporting a vulnerability

**Please don't open a public issue.** Report it privately through GitHub's
[private vulnerability reporting](https://github.com/jpechaves/steam_api/security/advisories/new)
(the repository's **Security** tab → **Report a vulnerability**).

Include the gem and Ruby versions, what an attacker could do, and how to reproduce it. Leave your
Steam Web API key out of the report. You should get an answer within a week. Once a fix is
released, the advisory is published with credit to you, unless you'd rather stay anonymous.

## The Steam Web API key

Steam only accepts the key in the query string (`?key=...`), so it is part of every authorized
request URL. The gem keeps it out of its own `inspect` output and error messages, but anything
that logs full request URLs (a proxy, an HTTP logging middleware) will record it. Treat such logs
as secrets, and rotate the key at <https://steamcommunity.com/dev/apikey> if it leaks.
