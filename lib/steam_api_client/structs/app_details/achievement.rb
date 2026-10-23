module SteamApiClient
  module Structs
    module AppDetails
      # Struct that holds the App/Game achievement highlighted information
      # @see https://wiki.teamfortress.com/wiki/User:RJackson/StorefrontAPI#appdetails
      class Achievement < Base
        attribute :name, Types::String
        attribute :path, Types::String
      end
    end
  end
end
