module SteamApiClient
  module Structs
    # Base struct used by the others client's structs.
    class Base < ::Dry::Struct
      transform_keys(&:to_sym)

      # Build the struct through the response from api.
      # @param [Hash] json_response - The json response received from api.
      # @return an instance of the Struct
      def self.build_from_response(json_response)
        new(**json_response)
      end
    end
  end
end
