module SteamApiClient
  module Structs
    module AppDetails
      # Struct that holds the App/Game requirement information
      # @see https://wiki.teamfortress.com/wiki/User:RJackson/StorefrontAPI#appdetails
      class Requirements < Base
        attribute :minimum?, Types::String
        attribute :recommended?, Types::String
      end
    end
  end
end
