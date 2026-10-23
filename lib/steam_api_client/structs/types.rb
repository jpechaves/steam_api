module SteamApiClient
  module Structs
    # Wrapper module to help use the dry types and easily extend them
    # when necessary
    module Types
      include ::Dry.Types(default: :nominal)

      module Optional
        String = ::Dry.Types::String.optional.default(nil)
        Integer = ::Dry.Types::Integer.optional.default(nil)
      end
    end
  end
end
