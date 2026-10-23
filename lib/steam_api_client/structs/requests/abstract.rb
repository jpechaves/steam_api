module SteamApiClient
  module Structs
    module Requests
      # @abstract class for a base API endpoint Request's struct
      class Abstract < SteamApiClient::Structs::Base
        # Returns the version value to create the request path
        # @abstract
        # @return [String] the version of the request path
        def version
          raise NoMethodError, "Override this method"
        end

        # Returns the interface value to create the request path
        # @abstract
        # @return [String] the interface of the request path
        def interface
          raise NoMethodError, "Override this method"
        end

        # Returns the API path value to create the request path
        # @abstract
        # @return [String] the API path of the request path
        def path
          raise NoMethodError, "Override this method"
        end

        # Returns the HTTP method used by the request.
        # @return [Symbol]
        def method
          :get
        end

        # Returns the query params needed for the HTTP request
        # @return [Hash]
        def query_params
          {}
        end

        # Return the class attributes as a Hash
        # @return [Hash]
        def body
          to_h
        end

        # Tells if the request require the api_token in the query params
        # @return [Boolean]
        def needs_authorization?
          true
        end

        # Tells the URL builder which format to choose from
        # @return [Symbol]
        def endpoint_kind
          :base_endpoint
        end
      end
    end
  end
end
