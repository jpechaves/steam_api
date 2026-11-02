module SteamApiClient
  # An app on the store's front page, from `featured` and `featured_categories`.
  # Every field but the ID is nil when Steam leaves it out.
  # @see https://wiki.teamfortress.com/wiki/User:RJackson/StorefrontAPI#featured
  FeaturedItem = Model.define(
    id: :integer,
    # 0 for apps
    type: [:integer, optional: true],
    name: [:string, optional: true],
    discounted: [:boolean, optional: true],
    discount_percent: [:integer, optional: true],
    # In cents. nil for free apps.
    original_price: [:integer, optional: true],
    final_price: [:integer, optional: true],
    currency: [:string, optional: true],
    # When the discount ends, in unix time. nil when not discounted.
    discount_expiration: [:integer, optional: true],
    large_capsule_image: [:string, optional: true],
    small_capsule_image: [:string, optional: true],
    header_image: [:string, optional: true],
    windows_available: [:boolean, optional: true],
    mac_available: [:boolean, optional: true],
    linux_available: [:boolean, optional: true],
    streaming_video_available: [:boolean, from: :streamingvideo_available, optional: true],
    # "full", "partial", or nil
    controller_support: [:string, optional: true]
  )
end
