module SteamApiClient
  # Built first, then named FeaturedCategories::Category below
  category = Model.define(
    # e.g. "cat_specials"
    id: :string,
    name: :string,
    items: [[FeaturedItem], default: []]
  )

  # The store front page's lists, from `featured_categories`. The spotlights,
  # daily deal, genres and trailers Steam also sends vary in shape, so they're
  # left to `retrieve_raw`.
  # @see https://wiki.teamfortress.com/wiki/User:RJackson/StorefrontAPI#featuredcategories
  FeaturedCategories = Model.define(
    specials: [category, optional: true],
    coming_soon: [category, optional: true],
    top_sellers: [category, optional: true],
    new_releases: [category, optional: true]
  )
  FeaturedCategories.const_set(:Category, category)
end
