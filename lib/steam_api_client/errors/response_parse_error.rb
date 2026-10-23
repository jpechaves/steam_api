module SteamApiClient
  module Errors
    # Raised when an API response can't be built into its response struct,
    # e.g. the body isn't a JSON object or doesn't match the struct's schema.
    # The underlying JSON or Dry::Struct error is available through #cause.
    class ResponseParseError < ::StandardError
      attr_reader :response

      # @param [SteamApiClient::Response] response Http response wrapper
      # @param [Class] response_struct The struct the response was built into
      # @return A new instance of ResponseParseError
      def initialize(response, response_struct)
        @response = response

        super("Unable to build #{response_struct} from the API response (status code: #{response.status_code})")
      end
    end
  end
end
