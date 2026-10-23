module SteamApiClient
  module Errors
    # Error class that wraps an Api request failed
    #
    class ApiError < ::StandardError
      # Initializes a request API custom error
      # @param [SteamApiClient::Response, nil] response Http response wrapper, nil when
      #   the request failed without one (e.g. it timed out)
      # @param [String, nil] message Overrides the message built from the response
      # @return A new instance of ApiError
      #
      def initialize(response = nil, message = nil)
        @http_status_code = response&.status_code
        @response = response
        @request = response&.request

        super(message || build_description_message)
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

    # Raised when the request times out (no response), or when Steam answers 408
    class HttpTimeout < ApiError; end

    # status_code: 400
    class HttpBadRequest < ApiError; end

    # status_code: 401
    class HttpUnauthorized < ApiError; end

    # status_code: 403
    class HttpForbidden < ApiError; end

    # status_code: 404
    class HttpNotFound < ApiError; end

    # status_code: 500
    class HttpInternalServerError < ApiError; end

    # Reads the Retry-After header of rate limited / unavailable responses
    module RetryAfter
      # Seconds to wait before retrying. Retry-After is either a number of
      # seconds or an HTTP date.
      # @return [Integer, nil] nil when the header is missing or invalid
      def retry_after
        value = response.headers&.[]("Retry-After").to_s.strip
        return Integer(value, 10) if value.match?(/\A\d+\z/)
        return if value.empty?

        [(Time.httpdate(value) - Time.now).ceil, 0].max
      rescue ArgumentError
        nil
      end
    end

    # status_code: 429. Steam rate limits frequent requests.
    class HttpTooManyRequests < ApiError
      include RetryAfter
    end

    # status_code: 502
    class HttpBadGateway < ApiError; end

    # status_code: 503
    class HttpServiceUnavailable < ApiError
      include RetryAfter
    end
  end
end
