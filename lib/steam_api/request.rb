module SteamApi
  class Request
    def initialize(request_struct:, response_struct:, client:)
      @failure_handler = SteamApi::FailureHandler.instance
      @request_struct = request_struct
      @response_struct = response_struct
      @client = client

      build_request
    end

    def run
      freeze

      raw_response = @raw_request.run

      Response.new(raw_response: raw_response, response_struct: response_struct, request: self).tap do |response|
        failure_handler.call(response)
      end
    end

    private

    attr_accessor :request_struct, :response_struct, :client, :raw_request, :failure_handler

    def build_request
      url = nil

      case request_struct.endpoint_kind
      when :base_endpoint then url = build_base_url
      when :storefront_endpoint then url = build_storefront_url
      else raise SteamApi::Errors::EndpointKindNotSupported
      end

      @raw_request = ::Typhoeus::Request.new(url.to_s, build_options)
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

    def build_options
      {
        method: request_struct.method,
        headers: default_headers,
        body: request_struct.body.to_json,
        followlocation: true,
        timeout_ms: (client.timeout * 1000).to_i,
        connecttimeout_ms: (client.connect_timeout * 1000).to_i,
        # Required for sub-second timeouts and safe use of timeouts across threads
        nosignal: true
      }
    end

    def default_headers
      {"Content-Type" => "application/json"}
    end
  end
end
