module SteamApiClient
  # The parts of PackageDetails, built first, then named under it below
  # (e.g. PackageDetails::App)
  parts = {
    App: Model.define(id: :integer, name: :string),
    Price: Model.define(
      currency: :string,
      # In cents
      initial: :integer,
      final: :integer,
      discount_percent: :integer,
      # The sum of the apps' own prices, in cents (0 when they aren't sold separately)
      individual: [:integer, optional: true]
    ),
    Controller: Model.define(full_gamepad: :boolean)
  }

  # A package (a bundle or a sub) in the store, from `package_details`. Every
  # field is nil when Steam leaves it out.
  # @see https://wiki.teamfortress.com/wiki/User:RJackson/StorefrontAPI#packagedetails
  PackageDetails = Model.define(
    package_id: [:integer, from: :packageid],
    name: [:string, optional: true],
    # HTML
    page_content: [:string, optional: true],
    purchase_text: [:string, optional: true],
    page_image: [:string, optional: true],
    header_image: [:string, optional: true],
    small_logo: [:string, optional: true],
    apps: [[parts[:App]], default: []],
    # Not sent for free packages
    price: [parts[:Price], optional: true],
    platforms: [AppDetails::Platforms, optional: true],
    controller: [parts[:Controller], optional: true],
    release_date: [AppDetails::ReleaseDate, optional: true]
  ) do
    # The package's data, or nil when it's unavailable (see AppDetails.unwrap)
    # @param [Hash] json
    # @return [Hash, nil]
    def self.unwrap(json)
      AppDetails.unwrap(json, id_key: :packageid)
    end
  end
  parts.each { |name, model| PackageDetails.const_set(name, model) }
end
