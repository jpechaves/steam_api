module SteamApiClient
  module Errors
    # Error class that wraps an Api request failed
    #
    class ApiError < ::StandardError
      # Initializes a request API custom error
      # @param [SteamApiClient::Response] Http response wrapper
      # @return A new instance of ApiError
      #
      def initialize(response)
        @http_status_code = response.status_code
        @response = response
        @request = response.request

        super(build_description_message)
      end

      private

      attr_accessor :http_status_code, :response

      def build_description_message
        <<~MESSAGE.split.join(" ")
          A request failed with the following status code: #{http_status_code}
          and body: #{response.body}
        MESSAGE
      end
    end

    # status_code: 400
    class HttpBadRequest < ApiError; end

    # status_code: 401
    class HttpUnauthorized < ApiError; end

    # status_code: 403
    class HttpForbidden < ApiError; end

    # status_code: 404
    class HttpNotFound < ApiError; end

    # status_code: 408
    class HttpTimeout < ApiError; end

    # status_code: 500
    class HttpInternalServerError < ApiError; end
  end
end
