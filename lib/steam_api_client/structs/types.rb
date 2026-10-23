module SteamApiClient
  module Structs
    # Types used by the structs. Steam's JSON often sends numbers as strings
    # (e.g. achievement percentages, ages), so scalar types coerce values, and
    # anything that can't be coerced raises instead of passing through.
    # Steam also sends null for values it doesn't have (e.g. an app's website),
    # so nil passes through every scalar type unchanged.
    module Types
      include ::Dry.Types(default: :nominal)

      Integer = Coercible::Integer.optional
      Float = Coercible::Float.optional
      # Numbers become strings
      String = Strict::String.constructor { |value| value.is_a?(::Numeric) ? value.to_s : value }.optional
      Bool = Strict::Bool.optional

      module Optional
        String = Types::String.optional.default(nil)
        Integer = Types::Integer.optional.default(nil)
      end
    end
  end
end
