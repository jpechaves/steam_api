module SteamApiClient
  module Structs
    module AppDetails
      # Struct that holds the App/Game genre information
      # @see https://wiki.teamfortress.com/wiki/User:RJackson/StorefrontAPI#appdetails
      class Genre < Base
        attribute :id, Types::Coercible::Integer
        attribute :description, Types::String
      end
    end
  end
end
