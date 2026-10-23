module SteamApiClient
  module Structs
    module Requests
      class GetAppNews < Abstract
        attribute :appid, Types::Integer
        attribute :count, Types::Integer
        attribute :maxlength, Types::Integer

        # Build the struct through the received params.
        # @params [Hash] params The hash params.
        # @return an instance of the Struct
        def self.build_from_params(params)
          %i[appid count maxlength].each do |attrib|
            raise ArgumentError, "#{attrib} is missing" unless params.key?(attrib)
          end

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
          "ISteamNews/"
        end

        # Returns the API path value to create the request path
        # @return [String] the API path of the request path
        def path
          "GetNewsForApp/"
        end

        # Returns the query params needed for the HTTP request
        # @return [Hash]
        def query_params
          {
            appid: appid,
            count: count,
            maxlength: maxlength
          }
        end

        # Return the class attributes as a Hash
        # @return [Hash]
        def body
          {}
        end

        # Tells if the request require the api_token in the query params
        # @return [Boolean]
        def needs_authorization?
          false
        end
      end
    end
  end
end
