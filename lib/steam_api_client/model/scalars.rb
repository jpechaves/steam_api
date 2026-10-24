module SteamApiClient
  module Model
    # Conversions of the scalar types
    module Scalars
      TYPES = %i[integer float number string boolean].freeze
      INTEGER = /\A-?\d+\z/
      FLOAT = /\A-?\d+(\.\d+)?\z/

      def self.method_for(type)
        raise ArgumentError, "unknown type #{type.inspect}" unless TYPES.include?(type)

        :"to_#{type}"
      end

      def self.to_integer(value)
        return value if value.is_a?(::Integer)
        return Integer(value, 10) if value.is_a?(::String) && value.match?(INTEGER)

        invalid("an Integer", value)
      end

      def self.to_float(value)
        return value.to_f if value.is_a?(::Integer) || value.is_a?(::Float)
        return Float(value) if value.is_a?(::String) && value.match?(FLOAT)

        invalid("a Float", value)
      end

      # Integer or Float, as Steam sends it (converting would truncate or change stats)
      def self.to_number(value)
        return value if value.is_a?(::Integer) || value.is_a?(::Float)
        return to_integer(value) if value.is_a?(::String) && value.match?(INTEGER)

        to_float(value)
      rescue Error
        invalid("a number", value)
      end

      def self.to_string(value)
        return value if value.is_a?(::String)
        return value.to_s if value.is_a?(::Numeric)

        invalid("a String", value)
      end

      # Steam's flags are true/false or 1/0
      def self.to_boolean(value)
        return value if value == true || value == false
        return value == 1 if value == 0 || value == 1

        invalid("true or false", value)
      end

      def self.invalid(expected, value)
        raise Error, "expected #{expected}, got #{value.class}"
      end
    end
  end
end
