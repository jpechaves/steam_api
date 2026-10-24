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
    # @param [SteamApiClient::Structs::Base] response_struct The struct necessary to
    #   build the response received from Api
    # @param [SteamApiClient::Request] request The wrapper Request class
    def initialize(raw_response:, response_struct:, request:)
      @raw_response = raw_response
      @response_struct = response_struct
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

    # Parses the response's json body and build the expected struct
    # @return [SteamApiClient::Structs::Base]
    # @raise [SteamApiClient::Errors::ResponseParseError] if the body isn't a JSON object
    #   or doesn't match the response struct
    def result
      json_response = parse_body
      raise TypeError, "expected a JSON object, got #{json_response.class}" unless json_response.is_a?(Hash)

      response_struct.build_from_response(json_response)
    rescue JSON::ParserError, TypeError, Dry::Struct::Error
      raise Errors::ResponseParseError.new(self, response_struct)
    end

    # Shows the status and the request, with the API token redacted
    # @return [String]
    def inspect
      "#<#{self.class.name} status=#{status_code} request=#{request.inspect}>"
    end

    private

    attr_accessor :raw_response, :response_struct

    # json 3 rejects duplicate keys by default; keep json 2's behavior (last one wins)
    # so a response parses the same whichever json version the app uses
    def parse_body
      ::JSON.parse(raw_response.body.to_s, symbolize_names: true, allow_duplicate_key: true)
    end
  end
end
