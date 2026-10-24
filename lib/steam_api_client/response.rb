require "forwardable"

module SteamApiClient
  # Wraps the raw response received from the Api
  class Response
    extend Forwardable

    # headers: the HTTP response headers (case-insensitive Faraday::Utils::Headers)
    def_delegators :@raw_response, :success?, :body, :headers
    attr_accessor :request

    # Initialize a new instance
    # @param [Faraday::Response] raw_response
    # @param [SteamApiClient::Endpoint] endpoint The endpoint called, which builds the result
    # @param [SteamApiClient::Request] request The wrapper Request class
    def initialize(raw_response:, endpoint:, request:)
      @raw_response = raw_response
      @endpoint = endpoint
      @request = request
    end

    # Check if the request was successful or not
    # @return [Boolean]
    def fail?
      !success?
    end

    # Returns the HTTP status code
    # @return [Integer]
    def status_code
      raw_response.status
    end

    # Parses the response's json body as a Hash. If the response body isn't a json
    # returns an empty hash
    # @return [Hash]
    def to_h
      parse_body
    rescue JSON::ParserError
      {}
    end

    # Steam's JSON, untouched (keys symbolized)
    # @return [Hash]
    # @raise [SteamApiClient::Errors::ResponseParseError] if the body isn't a JSON object
    def json
      parse_body.tap do |json|
        raise Model::Error, "expected a JSON object, got #{json.class}" unless json.is_a?(Hash)
      end
    rescue JSON::ParserError, Model::Error
      raise Errors::ResponseParseError.new(self, endpoint)
    end

    # The endpoint's result, built from the JSON body
    # @return [Data, Array, Integer, nil] see SteamApiClient::Endpoints
    # @raise [SteamApiClient::Errors::ResponseParseError] if the body isn't a JSON object
    #   or doesn't match the endpoint's result
    def result
      endpoint.result(json)
    rescue Model::Error
      raise Errors::ResponseParseError.new(self, endpoint)
    end

    # Shows the status and the request, with the API token redacted
    # @return [String]
    def inspect
      "#<#{self.class.name} status=#{status_code} request=#{request.inspect}>"
    end

    private

    attr_accessor :raw_response, :endpoint

    # json 3 rejects duplicate keys by default; keep json 2's behavior (last one wins)
    # so a response parses the same whichever json version the app uses
    def parse_body
      ::JSON.parse(raw_response.body.to_s, symbolize_names: true, allow_duplicate_key: true)
    end
  end
end
