module SteamApiClient
  class Request
    def initialize(request_struct:, response_struct:, client:)
      @failure_handler = SteamApiClient::FailureHandler.instance
      @request_struct = request_struct
      @response_struct = response_struct
      @client = client

      ensure_api_token!
      build_request
    end

    def run
      freeze

      raw_response = perform

      Response.new(raw_response: raw_response, response_struct: response_struct, request: self).tap do |response|
        failure_handler.call(response)
      end
    end

    private

    attr_accessor :request_struct, :response_struct, :client, :url, :failure_handler

    # Sends the request through the client's Faraday connection, turning
    # Faraday's network errors into the gem's errors (the original is #cause)
    def perform
      client.connection.run_request(request_struct.method, url, body, headers) do |request|
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

    # GET requests (every Steam endpoint so far) carry their params in the query string
    def body
      request_struct.body.to_json unless request_struct.method == :get
    end

    def headers
      return {} if request_struct.method == :get

      {"Content-Type" => "application/json"}
    end

    def ensure_api_token!
      return unless request_struct.needs_authorization?
      return unless client.api_token.to_s.empty?

      raise SteamApiClient::Errors::MissingApiToken
    end

    def build_request
      url = nil

      case request_struct.endpoint_kind
      when :base_endpoint then url = build_base_url
      when :storefront_endpoint then url = build_storefront_url
      else raise SteamApiClient::Errors::EndpointKindNotSupported
      end

      @url = url.to_s
    end

    def build_base_url
      url = URI.join(
        client.base_endpoint,
        request_struct.interface,
        request_struct.path,
        request_struct.version
      )
      url.query = query_params

      url
    end

    def build_storefront_url
      url = URI.join(
        client.storefront_endpoint,
        request_struct.path
      )
      url.query = query_params

      url
    end

    def query_params
      all_params = {}.tap do |params|
        params[:key] = client.api_token if request_struct.needs_authorization?
        params.merge!(request_struct.query_params)
      end

      URI.encode_www_form(all_params)
    end
  end
end
