module SteamApiClient
  # One Steam endpoint, declared in SteamApiClient::Endpoints. Turns the keyword
  # arguments given to its requestor's #retrieve into the request's query params.
  class Endpoint
    APIS = %i[web store].freeze

    # Reads the value at a path of keys, nil when a key is missing
    class KeyPath
      def initialize(keys)
        @keys = keys.dup.freeze
        freeze
      end

      # @raise [Model::Error] when the path goes through something that isn't an object
      def call(json)
        @keys.reduce(json) do |object, key|
          raise Model::Error, "expected an object at #{key.inspect}, got #{object.class}" unless object.nil? || object.is_a?(Hash)

          object&.[](key)
        end
      end
    end

    attr_reader :name, :path, :api, :params, :returns, :at

    # @param [Symbol] name the client method, e.g. :player_level
    # @param [String] path Web API: "<interface>/<method>/<version>/"; Storefront: "<method>/"
    # @param returns what #retrieve returns, as a Model type: a model, [model] for a list, or :integer
    # @param [Array<Symbol>, #call] at where the result is in Steam's JSON: a path of keys, or a callable
    #   that takes the JSON (the result is nil when a key is missing)
    # @param [Symbol] api :web (api.steampowered.com) or :store (store.steampowered.com/api)
    # @param [Boolean] key whether Steam needs the API key
    # @param [Hash{Symbol => Param}] params the keyword arguments of #retrieve, in query order
    def initialize(name, path, returns:, at: [], api: :web, key: true, params: {})
      raise ArgumentError, "api must be :web or :store, got #{api.inspect}" unless APIS.include?(api)

      @name = name
      @path = path.freeze
      @returns = returns
      @at = at.respond_to?(:call) ? at : KeyPath.new(at)
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

    # The result of a call, from Steam's JSON. Steam answers with an empty object when
    # the data isn't visible (e.g. a private profile), which is nil, or [] for lists.
    # @param [Hash] json the parsed response body, with symbol keys
    # @raise [Model::Error] if the JSON doesn't match the result's type
    def result(json)
      value = at.call(json)
      value = nil if value == {}
      return [] if value.nil? && returns.is_a?(Array)

      Model.cast(returns, value)
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
