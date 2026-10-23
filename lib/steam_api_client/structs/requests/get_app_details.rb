module SteamApiClient
  module Structs
    module Requests
      class GetAppDetails < StorefrontAbstract
        attribute :appid, Types::Integer
        attribute :filters, Types::Array.of(Types::String)
        attribute :cc, Types::String
        attribute :l, Types::String

        # Build the struct through the received params.
        # @params [Hash] params The hash params.
        # @return an instance of the Struct
        def self.build_from_params(params)
          %i[appid].each do |attrib|
            raise StandardError, "#{attrib} is missing" unless params.key?(attrib)
          end

          new(params)
        end

        # Returns the API path value to create the request path
        # @return [String] the API path of the request path
        def path
          "appdetails/"
        end

        # Returns the query params needed for the HTTP request
        # @return [Hash]
        def query_params
          super.merge(
            {
              appids: appid,
              filters: filters.join(","),
              cc: cc,
              l: l
            }
          )
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
