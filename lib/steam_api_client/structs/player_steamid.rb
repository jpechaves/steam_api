module SteamApiClient
  module Structs
    # Struct that holds the player SteamId
    # @see https://wiki.teamfortress.com/wiki/WebAPI/ResolveVanityURL
    class PlayerSteamId < Base
      attribute :response do
        # The 64 bit Steam ID the vanity URL resolves to. Not returned on resolution failures.
        attribute :steamid?, Types::Coercible::Integer.optional.default(nil)
        # The message associated with the request status. Currently only used on resolution failures.
        attribute :message?, Types::String
        # The status of the request. 1 if successful, 42 if there was no match.
        attribute :success, Types::Integer
      end
    end
  end
end
