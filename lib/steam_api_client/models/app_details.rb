module SteamApiClient
  # The parts of AppDetails, built first, then named under it below
  # (e.g. AppDetails::Category)
  parts = {
    Requirements: Model.define(
      # HTML
      minimum: [:string, optional: true],
      recommended: [:string, optional: true]
    ),
    Price: Model.define(
      currency: :string,
      # In cents
      initial: :integer,
      final: :integer,
      discount_percent: :integer,
      initial_formatted: :string,
      final_formatted: :string
    ),
    Package: Model.define(
      package_id: [:integer, from: :packageid],
      percent_savings_text: :string,
      percent_savings: :integer,
      option_text: :string,
      option_description: :string,
      can_get_free_license: :string,
      is_free_license: :boolean,
      price_in_cents_with_discount: :integer
    ),
    Platforms: Model.define(windows: :boolean, mac: :boolean, linux: :boolean),
    Metacritic: Model.define(score: :integer, url: :string),
    Category: Model.define(id: :integer, description: :string),
    Genre: Model.define(id: :integer, description: :string),
    Screenshot: Model.define(id: :integer, path_thumbnail: :string, path_full: :string),
    Movie: Model.define(
      id: :integer,
      name: :string,
      thumbnail: :string,
      # Streaming manifests (MPEG-DASH and HLS)
      dash_av1: [:string, optional: true],
      dash_h264: [:string, optional: true],
      hls_h264: [:string, optional: true],
      highlight: :boolean
    ),
    HighlightedAchievement: Model.define(name: :string, path: :string),
    ReleaseDate: Model.define(coming_soon: :boolean, date: :string),
    SupportInfo: Model.define(url: :string, email: :string),
    ContentDescriptors: Model.define(ids: [[:integer], default: []], notes: [:string, optional: true])
  }
  parts[:PackageGroup] = Model.define(
    name: :string,
    title: :string,
    description: :string,
    selection_text: :string,
    save_text: :string,
    display_type: :integer,
    is_recurring_subscription: :string,
    subs: [[parts[:Package]], default: []]
  )
  parts[:Achievements] = Model.define(
    total: :integer,
    highlighted: [[parts[:HighlightedAchievement]], default: []]
  )

  # An app's store page, from `app_details`. Every field is nil when Steam leaves
  # it out (e.g. when it isn't in the requested filters).
  # @see https://wiki.teamfortress.com/wiki/User:RJackson/StorefrontAPI#appdetails
  AppDetails = Model.define(
    app_id: [:integer, from: :steam_appid, optional: true],
    # "game", "dlc", "demo", "music"...
    type: [:string, optional: true],
    name: [:string, optional: true],
    required_age: [:integer, optional: true],
    is_free: [:boolean, optional: true],
    dlc: [[:integer], optional: true],
    # HTML
    detailed_description: [:string, optional: true],
    about_the_game: [:string, optional: true],
    short_description: [:string, optional: true],
    supported_languages: [:string, optional: true],
    header_image: [:string, optional: true],
    website: [:string, optional: true],
    pc_requirements: [parts[:Requirements], optional: true],
    mac_requirements: [parts[:Requirements], optional: true],
    linux_requirements: [parts[:Requirements], optional: true],
    developers: [[:string], optional: true],
    publishers: [[:string], optional: true],
    # Not sent for free apps
    price_overview: [parts[:Price], optional: true],
    packages: [[:integer], optional: true],
    package_groups: [[parts[:PackageGroup]], optional: true],
    platforms: [parts[:Platforms], optional: true],
    metacritic: [parts[:Metacritic], optional: true],
    categories: [[parts[:Category]], optional: true],
    genres: [[parts[:Genre]], optional: true],
    screenshots: [[parts[:Screenshot]], optional: true],
    movies: [[parts[:Movie]], optional: true],
    # Number of user reviews
    recommendations: [:integer, from: %i[recommendations total], optional: true],
    achievements: [parts[:Achievements], optional: true],
    release_date: [parts[:ReleaseDate], optional: true],
    support_info: [parts[:SupportInfo], optional: true],
    background: [:string, optional: true],
    background_raw: [:string, optional: true],
    content_descriptors: [parts[:ContentDescriptors], optional: true]
  ) do
    # Steam keys the response by app ID: {"570": {"success": true, "data": {...}}}.
    # Returns the data, or nil when the app is unavailable (success: false).
    # @param [Hash] json
    # @return [Hash, nil]
    def self.unwrap(json)
      app_id, entry = json.first
      return unless entry.is_a?(Hash) && entry[:success]

      {steam_appid: app_id.to_s}.merge(entry.fetch(:data, {}))
    end
  end
  parts.each { |name, model| AppDetails.const_set(name, model) }
end
