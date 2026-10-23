module SteamApiClient
  module Structs
    # Struct that holds all App news information
    # @see https://developer.valvesoftware.com/wiki/Steam_Web_API#GetNewsForApp_.28v0002.29
    class AppNews < Base
      attribute :appnews do
        attribute :appid?, Types::Integer
        attribute :count?, Types::Integer
        attribute :newsitems?, Types::Strict::Array.of(AppNew)
      end
    end
  end
end
