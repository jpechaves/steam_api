module SteamApiClient
  module Structs
    module AppDetails
      # Struct that holds the App/Game package group information
      # @see https://wiki.teamfortress.com/wiki/User:RJackson/StorefrontAPI#appdetails
      class PackageGroup < Base
        attribute :name, Types::String
        attribute :title, Types::String
        attribute :description, Types::String
        attribute :selection_text, Types::String
        attribute :save_text, Types::String
        attribute :display_type, Types::Coercible::Integer
        attribute :is_recurring_subscription, Types::String
        attribute :subs, Types::Array.of(SteamApiClient::Structs::AppDetails::Sub)
      end
    end
  end
end
