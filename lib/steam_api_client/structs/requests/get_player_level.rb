module SteamApiClient
  module Structs
    module Requests
      class GetPlayerLevel < Abstract
        attribute :steamid, Types::Integer

        # Build the struct through the received params.
        # @params [Hash] params The hash params.
        # @return an instance of the Struct
        def self.build_from_params(params)
          raise ArgumentError, ":steamid is missing" unless params.key?(:steamid)

          new(params)
        end

        # Returns the version value to create the request path
        # @return [String] the version of the request path
        def version
          "v0001/"
        end

        # Returns the interface value to create the request path
        # @return [String] the interface of the request path
        def interface
          "IPlayerService/"
        end

        # Returns the API path value to create the request path
        # @return [String] the API path of the request path
        def path
          "GetSteamLevel/"
        end

        # Returns the query params needed for the HTTP request
        # @return [Hash]
        def query_params
          {steamid: steamid}
        end
      end
    end
  end
end
