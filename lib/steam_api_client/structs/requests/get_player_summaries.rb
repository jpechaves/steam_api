module SteamApiClient
  module Structs
    module Requests
      class GetPlayerSummaries < Abstract
        attribute :steamids, Types::Array.of(Types::Coercible::Integer)

        # Build the struct through the received params.
        # @params [Hash] params The hash params.
        # @return an instance of the Struct
        def self.build_from_params(params)
          raise StandardError, ":steamids are missing" unless params.key?(:steamids)

          new(params)
        end

        # Returns the version value to create the request path
        # @return [String] the version of the request path
        def version
          "v0002/"
        end

        # Returns the interface value to create the request path
        # @return [String] the interface of the request path
        def interface
          "ISteamUser/"
        end

        # Returns the API path value to create the request path
        # @return [String] the API path of the request path
        def path
          "GetPlayerSummaries/"
        end

        # Returns the query params needed for the HTTP request
        # @return [Hash]
        def query_params
          # I need to join the steamids because they wont accept
          # multiple equal keys with different values on query params
          {
            steamids: steamids.join(",")
          }
        end

        # Return the class attributes as a Hash
        # @return [Hash]
        def body
          {}
        end
      end
    end
  end
end
