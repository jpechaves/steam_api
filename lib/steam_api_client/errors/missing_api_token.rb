module SteamApiClient
  module Errors
    # Raised before a request is sent when the endpoint needs an API token
    # and the client has none
    class MissingApiToken < ::StandardError
      def initialize(message = "This endpoint needs a Steam Web API token. Pass Client.new(api_token: ...) or set it with Client.configure { |config| config.api_token = ... }.")
        super
      end
    end
  end
end
