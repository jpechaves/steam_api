module SteamApiClient
  module Structs
    module Requests
      class GetPlayerFriends < Abstract
        attribute :steamid, Types::Integer
        attribute :relationship, Types::String

        # Build the struct through the received params.
        # @params [Hash] params The hash params.
        # @return an instance of the Struct
        def self.build_from_params(params)
          %i[steamid relationship].each do |attrib|
            raise ArgumentError, "#{attrib} is missing" unless params.key?(attrib)
          end

          # The only possible values are: all, friend.
          raise ArgumentError, ":relationship value not allowed" unless %w[all friend].include? params[:relationship]

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
          "ISteamUser/"
        end

        # Returns the API path value to create the request path
        # @return [String] the API path of the request path
        def path
          "GetFriendList/"
        end

        # Returns the query params needed for the HTTP request
        # @return [Hash]
        def query_params
          {
            steamid: steamid,
            relationship: relationship
          }
        end
      end
    end
  end
end
