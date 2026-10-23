module SteamApiClient
  module Structs
    module AppDetails
      # Struct that holds the App/Game video (movies, trailers etc) information
      # @see https://wiki.teamfortress.com/wiki/User:RJackson/StorefrontAPI#appdetails
      class Movie < Base
        attribute :id, Types::Coercible::Integer
        attribute :name, Types::String
        attribute :thumbnail, Types::String
        # Streaming manifests (MPEG-DASH and HLS) returned by the current Storefront API
        attribute? :dash_av1, Types::String
        attribute? :dash_h264, Types::String
        attribute? :hls_h264, Types::String
        # Legacy direct video files, no longer returned by Steam
        attribute? :webm do
          attribute :max, Types::String
        end
        attribute? :mp4 do
          attribute :max, Types::String
        end
        attribute :highlight, Types::Bool
      end
    end
  end
end
