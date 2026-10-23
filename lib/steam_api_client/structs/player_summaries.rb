module SteamApiClient
  module Structs
    # Struct that holds the Player Summaries information
    # @see https://developer.valvesoftware.com/wiki/Steam_Web_API#GetPlayerSummaries_.28v0002.29
    class PlayerSummaries < Base
      attribute :response do
        attribute :players, Types::Strict::Array.of(PlayerSummary)
      end
    end
  end
end
