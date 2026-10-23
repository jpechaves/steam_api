module SteamApiClient
  module Structs
    module AppDetails
      # Struct that holds the App/Game screenshot information
      # @see https://wiki.teamfortress.com/wiki/User:RJackson/StorefrontAPI#appdetails
      class Screenshot < Base
        attribute :id, Types::Coercible::Integer
        attribute :path_thumbnail, Types::String
        attribute :path_full, Types::String
      end
    end
  end
end
