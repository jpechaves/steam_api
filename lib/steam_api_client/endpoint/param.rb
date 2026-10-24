module SteamApiClient
  class Endpoint
    # A query param: checks and converts the value given to #retrieve
    class Param
      TYPES = %i[integer integer_list string string_list boolean].freeze
      NO_DEFAULT = Object.new.freeze
      private_constant :NO_DEFAULT

      attr_reader :type, :as, :default, :allowed

      TYPES.each do |type|
        define_singleton_method(type) { |**options| new(type, **options) }
      end

      # @param [Symbol] type one of TYPES
      # @param [Symbol, nil] as the name Steam uses for the param, when it differs
      # @param default the value used when the keyword isn't given. Without one, the keyword is required.
      # @param [Array, nil] in the only values allowed
      def initialize(type, as: nil, default: NO_DEFAULT, in: nil)
        raise ArgumentError, "type must be one of #{TYPES.inspect}, got #{type.inspect}" unless TYPES.include?(type)

        @type = type
        @as = as
        @default = default
        @allowed = binding.local_variable_get(:in)
        freeze
      end

      def required?
        default.equal?(NO_DEFAULT)
      end

      # @return the value as sent to Steam
      # @raise [ArgumentError] if the value has the wrong type or isn't allowed
      def convert(name, value)
        converted = send(:"convert_#{type}", name, value)
        return converted if allowed.nil? || allowed.include?(converted)

        raise ArgumentError, "#{name} must be one of #{allowed.map(&:inspect).join(", ")}, got #{value.inspect}"
      end

      private

      def convert_integer(name, value)
        return value if value.is_a?(::Integer)
        return Integer(value, 10) if value.is_a?(::String) && value.match?(/\A-?\d+\z/)

        invalid(name, "an Integer", value)
      end

      def convert_string(name, value)
        return value.to_s if value.is_a?(::String) || value.is_a?(::Symbol)

        invalid(name, "a String", value)
      end

      def convert_boolean(name, value)
        return value if value == true || value == false

        invalid(name, "true or false", value)
      end

      # Lists are sent comma-separated
      def convert_integer_list(name, value)
        list(name, value) { |item| convert_integer(name, item) }
      end

      def convert_string_list(name, value)
        list(name, value) { |item| convert_string(name, item) }
      end

      def list(name, value, &)
        invalid(name, "an Array", value) unless value.is_a?(::Array)

        value.map(&).join(",")
      end

      def invalid(name, expected, value)
        raise ArgumentError, "#{name} must be #{expected}, got #{value.inspect}"
      end
    end
  end
end
