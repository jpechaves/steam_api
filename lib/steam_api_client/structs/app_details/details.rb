module SteamApiClient
  module Structs
    module AppDetails
      # Struct that holds the App/Game details information
      # @see https://wiki.teamfortress.com/wiki/User:RJackson/StorefrontAPI#appdetails
      class Details < Base
        attribute :appid, Types::Coercible::Integer
        attribute :response do
          attribute :success, Types::Bool
          # Steam omits data when the app is unavailable (success: false)
          attribute? :data do
            attribute? :type, Types::String
            attribute? :name, Types::String
            attribute? :required_age, Types::Coercible::Integer
            attribute? :is_free, Types::Bool
            attribute? :dlc, Types::Array.of(Types::Coercible::Integer)
            attribute? :detailed_description, Types::String
            attribute? :about_the_game, Types::String
            attribute? :short_description, Types::String
            attribute? :supported_languages, Types::String
            attribute? :header_image, Types::String
            attribute? :website, Types::String
            attribute? :pc_requirements, SteamApiClient::Structs::AppDetails::Requirements
            attribute? :mac_requirements, SteamApiClient::Structs::AppDetails::Requirements
            attribute? :linux_requirements, SteamApiClient::Structs::AppDetails::Requirements
            attribute? :developers, Types::Array.of(Types::Coercible::String)
            attribute? :publishers, Types::Array.of(Types::Coercible::String)
            attribute? :price_overview do
              attribute :currency, Types::String
              attribute :initial, Types::Coercible::Integer
              attribute :final, Types::Coercible::Integer
              attribute :discount_percent, Types::Coercible::Integer
              attribute :initial_formatted, Types::String
              attribute :final_formatted, Types::String
            end
            attribute? :packages, Types::Array.of(Types::Coercible::Integer)
            attribute? :package_groups, Types::Array.of(SteamApiClient::Structs::AppDetails::PackageGroup)
            attribute? :platforms do
              attribute :windows, Types::Bool
              attribute :mac, Types::Bool
              attribute :linux, Types::Bool
            end
            attribute? :metacritic do
              attribute :score, Types::Coercible::Integer
              attribute :url, Types::String
            end
            attribute? :categories, Types::Array.of(SteamApiClient::Structs::AppDetails::Category)
            attribute? :genres, Types::Array.of(SteamApiClient::Structs::AppDetails::Genre)
            attribute? :screenshots, Types::Array.of(SteamApiClient::Structs::AppDetails::Screenshot)
            attribute? :movies, Types::Array.of(SteamApiClient::Structs::AppDetails::Movie)
            attribute? :recommendations do
              attribute :total, Types::Coercible::Integer
            end
            attribute? :achievements do
              attribute :total, Types::Coercible::Integer
              attribute :highlighted, Types::Array.of(SteamApiClient::Structs::AppDetails::Achievement)
            end
            attribute? :release_date do
              attribute :coming_soon, Types::Bool
              attribute :date, Types::String
            end
            attribute? :support_info do
              attribute :url, Types::String
              attribute :email, Types::String
            end
            attribute? :background, Types::String
            attribute? :background_raw, Types::String
            attribute? :content_descriptors do
              attribute :ids, Types::Array.of(Types::Coercible::Integer)
              attribute :notes, Types::String
            end
          end
        end

        def self.build_from_response(json_response)
          outer_key = json_response.keys.first
          new(appid: outer_key.to_s, response: json_response[outer_key])
        end
      end
    end
  end
end
