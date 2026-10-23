module SteamApiClient
  module Requestors
    # Class that expose the necessary method(s) to get the news of an
    # app in the Steam Web Api.
    class AppNews < Base
      # Get on the Api one or more news of an App in the Steam.
      # @param [Integer] appid The Steam app id
      # @param [Integer] count The number of wanted news
      # @param [Integer] maxlength The max length of the news content
      # @return [SteamApiClient::Structs::AppNews] instance with the
      #   player summary details.
      def retrieve(appid:, count:, maxlength: 300)
        build_request_and_run(
          SteamApiClient::Structs::Requests::GetAppNews,
          SteamApiClient::Structs::AppNews,
          appid: appid,
          count: count,
          maxlength: maxlength
        )
      end
    end
  end
end
