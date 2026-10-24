module SteamApiClient
  module Errors
    # Raised when an API response can't be read into the endpoint's result,
    # e.g. the body isn't a JSON object or doesn't match the result's model.
    # The underlying JSON or SteamApiClient::Model::Error is available through #cause.
    class ResponseParseError < ::StandardError
      attr_reader :response

      # @param [SteamApiClient::Response] response Http response wrapper
      # @param [SteamApiClient::Endpoint] endpoint The endpoint called
      # @return A new instance of ResponseParseError
      def initialize(response, endpoint)
        @response = response

        super("Unable to read the #{endpoint.name} result from the API response (status code: #{response.status_code})")
      end
    end
  end
end
