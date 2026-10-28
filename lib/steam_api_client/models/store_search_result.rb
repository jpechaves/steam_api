module SteamApiClient
  # Built first, then named StoreSearchResult::Price below
  price = Model.define(
    currency: :string,
    # In cents
    initial: :integer,
    final: :integer
  )

  # One result of a store search, from `store_search`
  StoreSearchResult = Model.define(
    id: :integer,
    # "app"
    type: :string,
    name: :string,
    # Not sent for free apps
    price: [price, optional: true],
    tiny_image: [:string, optional: true],
    # nil when the app has no Metacritic score
    metascore: [:integer, optional: true],
    platforms: [AppDetails::Platforms, optional: true],
    streaming_video: [:boolean, from: :streamingvideo, optional: true],
    # "full", "partial", or nil
    controller_support: [:string, optional: true]
  ) do
    # The results. Steam sends "" as the metascore of apps without one.
    # @param [Hash] json
    # @return [Array<Hash>, nil]
    def self.unwrap(json)
      json[:items]&.map { |item| (item[:metascore] == "") ? item.merge(metascore: nil) : item }
    end
  end
  StoreSearchResult.const_set(:Price, price)
end
