module SteamApiClient
  # The parts of AppDlc, built first, then named under it below (e.g. AppDlc::Dlc)
  parts = {
    Price: Model.define(
      currency: :string,
      # In cents
      initial: :integer,
      final: :integer,
      discount_percent: :integer
    ),
    # Unix times, per platform. Steam sometimes adds milliseconds, which makes them Floats.
    ReleaseDates: Model.define(
      steam: [:number, optional: true],
      mac: [:number, optional: true],
      linux: [:number, optional: true]
    )
  }
  parts[:Dlc] = Model.define(
    id: :integer,
    name: :string,
    header_image: [:string, optional: true],
    # Not sent for free DLC, or DLC not sold on its own
    price_overview: [parts[:Price], optional: true],
    platforms: [AppDetails::Platforms, optional: true],
    release_date: [parts[:ReleaseDates], optional: true],
    # "full", "partial", or nil
    controller_support: [:string, optional: true]
  )

  # An app's DLC, from `app_dlc`
  AppDlc = Model.define(
    app_id: [:integer, from: :appid],
    name: :string,
    dlc: [[parts[:Dlc]], default: []]
  ) do
    # Steam answers {"status": 2} for an unknown app
    # @param [Hash] json
    # @return [Hash, nil] the JSON, or nil when the app is unknown
    def self.unwrap(json)
      json if json[:status] == 1
    end
  end
  parts.each { |name, model| AppDlc.const_set(name, model) }
end
