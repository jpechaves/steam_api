module SteamApiClient
  module Structs
    module Requests
      class GetPlayerAchievements < Abstract
        attribute :appid, Types::Integer
        attribute :steamid, Types::Integer

        # Build the struct through the received params.
        # @params [Hash] params The hash params.
        # @return an instance of the Struct
        def self.build_from_params(params)
          %i[appid steamid].each do |attrib|
            raise ArgumentError, "#{attrib} is missing" unless params.key?(attrib)
          end

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
          "ISteamUserStats/"
        end

        # Returns the API path value to create the request path
        # @return [String] the API path of the request path
        def path
          "GetPlayerAchievements/"
        end

        # Returns the query params needed for the HTTP request
        # @return [Hash]
        def query_params
          {
            appid: appid,
            steamid: steamid
          }
        end
      end
    end
  end
end
