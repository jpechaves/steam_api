module SteamApiClient
  # Built first, then named AppList::App below
  app = Model.define(
    app_id: [:integer, from: :appid],
    name: :string,
    # In unix time
    last_modified: [:integer, optional: true],
    # Changes whenever the app's price changes
    price_change_number: [:integer, optional: true]
  )

  # One page of the apps in the store, from `app_list`
  # @see https://steamapi.xpaw.me/#IStoreService/GetAppList
  AppList = Model.define(
    apps: [[app], default: []],
    # Steam leaves these out on the last page
    have_more_results: [:boolean, default: false],
    # Pass as `last_appid:` to get the next page
    last_app_id: [:integer, from: :last_appid, optional: true]
  )
  AppList.const_set(:App, app)
end
