module SteamApiClient
  # Class that checks an Api response and raise the correct exception
  class FailureHandler
    include Singleton

    # Perform the check
    # @param [SteamApiClient::Response] the response received from the Api
    # @return [NilClass] if response was successful
    # @raise [SteamApiClient::Errors::ApiError] if response was a failure.
    def call(response)
      return unless response.fail?

      raise_timedout(response) if response.timed_out?

      raise_response_4xx(response) if (400..499).cover?(response.status_code)
      raise_response_5xx(response) if (500..599).cover?(response.status_code)

      raise_api_error(response)
    end

    private

    def raise_timedout(response)
      raise SteamApiClient::Errors::HttpTimeout, response
    end

    def raise_response_4xx(response)
      case response.status_code
      when 400 then raise SteamApiClient::Errors::HttpBadRequest, response
      when 401 then raise SteamApiClient::Errors::HttpUnauthorized, response
      when 403 then raise SteamApiClient::Errors::HttpForbidden, response
      when 404 then raise SteamApiClient::Errors::HttpNotFound, response
      when 429 then raise SteamApiClient::Errors::HttpTooManyRequests, response
      end
    end

    def raise_response_5xx(response)
      case response.status_code
      when 500 then raise SteamApiClient::Errors::HttpInternalServerError, response
      when 502 then raise SteamApiClient::Errors::HttpBadGateway, response
      when 503 then raise SteamApiClient::Errors::HttpServiceUnavailable, response
      end
    end

    def raise_api_error(response)
      raise SteamApiClient::Errors::ApiError, response
    end
  end
end
