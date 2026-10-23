module SteamApiClient
  module Structs
    # Struct that holds an App news information
    # @see https://developer.valvesoftware.com/wiki/Steam_Web_API#GetNewsForApp_.28v0002.29
    class AppNew < Dry::Struct
      attribute :gid, Types::String
      attribute :title, Types::String
      attribute :url, Types::String
      attribute :is_external_url, Types::Bool
      attribute :author, Types::String
      attribute :contents, Types::String
      attribute :feedlabel, Types::String
      attribute :date, Types::Integer
      attribute :feedname, Types::String
      attribute :feed_type, Types::Integer
      attribute :appid, Types::Integer
      attribute :tags?, Types::Strict::Array.of(Types::String).optional
    end
  end
end
