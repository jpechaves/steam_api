module SteamApiClient
  module Structs
    module AppDetails
      # Struct that holds the App/Game category information
      # @see https://wiki.teamfortress.com/wiki/User:RJackson/StorefrontAPI#appdetails
      class Category < Base
        attribute :id, Types::Coercible::Integer
        attribute :description, Types::String
      end
    end
  end
end
