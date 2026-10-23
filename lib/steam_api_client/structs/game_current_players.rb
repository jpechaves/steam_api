module SteamApiClient
  module Structs
    # Struct that holds the number of current players for a game/appid
    # @see https://wiki.teamfortress.com/wiki/WebAPI/GetNumberOfCurrentPlayers
    class GameCurrentPlayers < Base
      attribute :response do
        attribute :player_count?, Types::Coercible::Integer
        attribute :result, Types::Coercible::Integer
      end
    end
  end
end
