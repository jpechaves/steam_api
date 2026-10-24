module SteamApiClient
  # A news item of an app, from `app_news`
  # @see https://developer.valvesoftware.com/wiki/Steam_Web_API#GetNewsForApp_.28v0002.29
  NewsItem = Model.define(
    gid: :string,
    title: :string,
    url: :string,
    is_external_url: :boolean,
    author: :string,
    # Shortened to the requested maxlength
    contents: :string,
    feed_label: [:string, from: :feedlabel],
    # Publication date, in unix time
    date: :integer,
    feed_name: [:string, from: :feedname],
    feed_type: :integer,
    app_id: [:integer, from: :appid],
    tags: [[:string], optional: true]
  )
end
