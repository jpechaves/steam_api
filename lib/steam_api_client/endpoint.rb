module SteamApiClient
  # One Steam endpoint, declared in SteamApiClient::Endpoints. Turns the keyword
  # arguments given to its requestor's #retrieve into the request's query params.
  class Endpoint
    APIS = %i[web store].freeze

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

    attr_reader :name, :path, :api, :params, :returns

    # @param [Symbol] name the client method, e.g. :player_level
    # @param [String] path Web API: "<interface>/<method>/<version>/"; Storefront: "<method>/"
    # @param [Class] returns the response struct
    # @param [Symbol] api :web (api.steampowered.com) or :store (store.steampowered.com/api)
    # @param [Boolean] key whether Steam needs the API key
    # @param [Hash{Symbol => Param}] params the keyword arguments of #retrieve, in query order
    def initialize(name, path, returns:, api: :web, key: true, params: {})
      raise ArgumentError, "api must be :web or :store, got #{api.inspect}" unless APIS.include?(api)

      @name = name
      @path = path.freeze
      @returns = returns
      @api = api
      @key = key
      @params = params.freeze
      freeze
    end

    def key?
      @key
    end

    # The query params for the given keyword arguments, with defaults applied
    # @param [Hash] arguments the keyword arguments given to #retrieve
    # @return [Hash] params named as Steam expects them, in declaration order
    # @raise [ArgumentError] on missing or unknown keywords, and invalid values
    def query(arguments)
      check_keywords(arguments)

      params.each_with_object({}) do |(name, param), query|
        query[param.as || name] = param.convert(name, arguments.fetch(name) { param.default })
      end
    end

    private

    # Same errors, and messages, as Ruby's own keyword arguments
    def check_keywords(arguments)
      missing = params.select { |name, param| param.required? && !arguments.key?(name) }.keys
      raise ArgumentError, keyword_error("missing", missing) if missing.any?

      unknown = arguments.keys - params.keys
      raise ArgumentError, keyword_error("unknown", unknown) if unknown.any?
    end

    def keyword_error(kind, names)
      "#{kind} keyword#{"s" if names.size > 1}: #{names.map(&:inspect).join(", ")}"
    end
  end
end
