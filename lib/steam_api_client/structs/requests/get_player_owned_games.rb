module SteamApiClient
  module Structs
    module Requests
      class GetPlayerOwnedGames < Abstract
        attribute :steamid, Types::Integer
        attribute :include_appinfo, Types::Bool
        attribute :include_played_free_games, Types::Bool

        # Build the struct through the received params.
        # @params [Hash] params The hash params.
        # @return an instance of the Struct
        def self.build_from_params(params)
          %i[steamid include_appinfo include_played_free_games].each do |attrib|
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
          "IPlayerService/"
        end

        # Returns the API path value to create the request path
        # @return [String] the API path of the request path
        def path
          "GetOwnedGames/"
        end

        # Returns the query params needed for the HTTP request
        # @return [Hash]
        def query_params
          {
            steamid: steamid,
            include_appinfo: include_appinfo,
            include_played_free_games: include_played_free_games
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
