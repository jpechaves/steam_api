module SteamApiClient
  # The apps featured on the store's front page, from `featured`
  # @see https://wiki.teamfortress.com/wiki/User:RJackson/StorefrontAPI#featured
  Featured = Model.define(
    large_capsules: [[FeaturedItem], default: []],
    featured_win: [[FeaturedItem], default: []],
    featured_mac: [[FeaturedItem], default: []],
    featured_linux: [[FeaturedItem], default: []],
    # The front page's layout, e.g. "defcon1"
    layout: [:string, optional: true]
  )
end
