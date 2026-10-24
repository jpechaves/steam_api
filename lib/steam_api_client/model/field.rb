module SteamApiClient
  module Model
    # One field of a model: where to read it in Steam's JSON and how to convert it
    class Field
      MISSING = Object.new.freeze
      private_constant :MISSING

      attr_reader :name, :type

      def initialize(name, type, from: name, optional: false, default: nil)
        @name = name
        @type = type
        @path = Array(from)
        @optional = optional || !default.nil?
        @default = default.frozen? ? default : default.dup.freeze
      end

      # @param [Hash] json the model's JSON object
      # @return the converted value
      # @raise [Model::Error] naming the field
      def read(json)
        value = dig(json)
        raise Error, "missing key #{@path.last.inspect}" if value.equal?(MISSING) && !@optional
        return @default if value.equal?(MISSING) || value.nil?

        Model.cast(type, value)
      rescue Error => error
        raise Error, "#{name}: #{error.message}"
      end

      private

      def dig(json)
        @path.reduce(json) do |object, key|
          return MISSING unless object.is_a?(Hash) && object.key?(key)

          object[key]
        end
      end
    end
  end
end
