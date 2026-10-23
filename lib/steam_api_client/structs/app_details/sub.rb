module SteamApiClient
  module Structs
    module AppDetails
      # Struct that holds the App/Game package group sub information
      # @see https://wiki.teamfortress.com/wiki/User:RJackson/StorefrontAPI#appdetails
      class Sub < Base
        attribute :packageid, Types::Coercible::Integer
        attribute :percent_savings_text, Types::String
        attribute :percent_savings, Types::Coercible::Integer
        attribute :option_text, Types::String
        attribute :option_description, Types::String
        attribute :can_get_free_license, Types::String
        attribute :is_free_license, Types::Bool
        attribute :price_in_cents_with_discount, Types::Coercible::Integer
      end
    end
  end
end
