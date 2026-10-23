module SteamApiClient
  module Structs
    # Struct that holds the user level on Steam
    # @see https://wiki.teamfortress.com/wiki/WebAPI/GetSteamLevel
    class PlayerLevel < Base
      attribute :response do
        attribute :player_level?, Types::Integer
      end
    end
  end
end
