module SteamApiClient
  # One call to an endpoint: builds the URL from the arguments and sends it
  # through the client's Faraday connection
  class Request
    # The API token in a request URL's query string
    API_KEY_PARAM = /(?<=[?&]key=)[^&]*/

    # @param [SteamApiClient::Endpoint] endpoint
    # @param [Hash] params the keyword arguments given to #retrieve
    # @param [SteamApiClient::Client] client
    # @raise [ArgumentError] on missing, unknown or invalid params
    # @raise [SteamApiClient::Errors::MissingApiToken] if the endpoint needs a token and the client has none
    def initialize(endpoint:, params:, client:)
      @failure_handler = SteamApiClient::FailureHandler.instance
      @endpoint = endpoint
      @client = client

      query = endpoint.query(params)
      ensure_api_token!
      @url = build_url(query)
    end

    def run
      freeze

      raw_response = perform

      Response.new(raw_response: raw_response, endpoint: endpoint, request: self).tap do |response|
        failure_handler.call(response)
      end
    end

    # Shows the method and the URL, with the API token redacted
    # @return [String]
    def inspect
      "#<#{self.class.name} GET #{url.sub(API_KEY_PARAM, "[REDACTED]")}>"
    end

    private

    attr_reader :endpoint, :client, :url, :failure_handler

    # Sends the request through the client's Faraday connection, turning
    # Faraday's network errors into the gem's errors (the original is #cause).
    # Every Steam endpoint is a GET, with its params in the query string.
    def perform
      client.connection.run_request(:get, url, nil, nil) do |request|
        request_options.each { |option, value| request.options.public_send(:"#{option}=", value) }
      end
    rescue ::Faraday::TimeoutError
      raise_timeout
    rescue ::Faraday::ConnectionFailed => error
      # Faraday reports a connect timeout (Net::OpenTimeout) as ConnectionFailed
      raise_timeout if error.wrapped_exception.is_a?(::Timeout::Error)
      raise SteamApiClient::Errors::ConnectionError, "Could not connect to Steam: #{error.message}"
    rescue ::Faraday::SSLError => error
      raise SteamApiClient::Errors::ConnectionError, "Could not connect to Steam: #{error.message}"
    end

    def raise_timeout
      raise SteamApiClient::Errors::HttpTimeout.new(
        nil, "The request to Steam timed out (timeout: #{client.timeout}s, connect_timeout: #{client.connect_timeout}s)"
      )
    end

    def request_options
      {timeout: client.timeout, open_timeout: client.connect_timeout}
    end

    def ensure_api_token!
      return unless endpoint.key?
      return unless client.api_token.to_s.empty?

      raise SteamApiClient::Errors::MissingApiToken
    end

    # The API key goes first, then the endpoint's params
    def build_url(query)
      query = {key: client.api_token}.merge(query) if endpoint.key?
      base = (endpoint.api == :store) ? client.storefront_endpoint : client.base_endpoint

      url = URI.join(base, endpoint.path)
      url.query = URI.encode_www_form(query)
      url.to_s
    end
  end
end
