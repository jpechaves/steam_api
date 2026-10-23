module SteamApi
  module Structs
    module Requests
      # @abstract class for a Storefront Request's struct
      class StorefrontAbstract < SteamApi::Structs::Base
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

        # Returns the query params needed for the HTTP request.
        # Here's a list taken from the steam website:
        # cc (Optional)
        #   Country code for method to return appropriate currency values.
        # l (Optional)
        #   For localized strings; takes English name of language (none of those fancy ISO distractions).
        # v (Optional)
        #   Unknown.
        # Given that information, I'm going to default the currency to 'USD' and locale to 'en'.
        #
        # @see https://wiki.teamfortress.com/wiki/User:RJackson/StorefrontAPI#Global_parameters
        # @return [Hash]
        def query_params
          {
            cc: "US",
            l: "en"
          }
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
          :storefront_endpoint
        end
      end
    end
  end
end
