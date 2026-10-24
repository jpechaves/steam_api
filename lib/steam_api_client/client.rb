# frozen_string_literal: true

module SteamApiClient
  # Main class to interact with the Steam Api.

  # Before using this client, you need to configure the
  # credentials through the 'SteamApiClient::Client.configure' method:
  #
  # ```ruby
  # SteamApiClient::Client.configure do |config|
  #   config.api_token = 'token-value'
  # end
  # ```
  #
  # All API calls take the form:
  # http://api.steampowered.com/<interface name>/<method name>/<version>/?key=<api key>&format=<format>.
  # Format can be any of:
  #   json - The output will be returned in the JSON format
  #   xml - Output is returned as an XML document
  #   vdf - Output is returned as a VDF file.
  # If you do not specify a format, your results will be returns in the JSON format.
  #
  # As we dive deeper into the implementation and find more endpoints to include in this
  # gem, some changes were needed to support the storefront API which is what Steam's
  # Big Picture Mode uses.
  # All API calls take the form:
  # https://store.steampowered.com/api/<method>?appids=1,2,3&filters=basic,recommendations
  # For more information, vist: https://wiki.teamfortress.com/wiki/User:RJackson/StorefrontAPI
  class Client
    BASE_ENDPOINT = "https://api.steampowered.com"
    STOREFRONT_API_ENDPOINT = "https://store.steampowered.com/api/"
    DEFAULT_TIMEOUT = Configuration::DEFAULT_TIMEOUT
    DEFAULT_CONNECT_TIMEOUT = Configuration::DEFAULT_CONNECT_TIMEOUT
    DEFAULT_ADAPTER = Configuration::DEFAULT_ADAPTER

    # Built eagerly, so threads never race to create it
    @config = Configuration.new

    class << self
      # The global settings shared by every client
      # @return [SteamApiClient::Configuration]
      attr_reader :config

      # SteamApiClient::Client.configure { |config| config.api_token = "..." }
      # @yieldparam [SteamApiClient::Configuration] config
      # @return [Class] the client class
      def configure
        yield config
        self
      end

      # Restores the default settings (e.g. between specs)
      # @return [SteamApiClient::Configuration]
      def reset_config!
        @config = Configuration.new
      end
    end

    attr_writer :api_token, :timeout, :connect_timeout

    # One method per endpoint, e.g. client.player_level.retrieve(steamid: ...)
    # @see SteamApiClient::Endpoints
    Endpoints::ALL.each_key do |name|
      define_method(name) { @requestors.fetch(name) }
    end

    # Initialize the client
    # @param [String] api_token - An existing api token.
    # @param [Numeric] timeout - Request timeout in seconds. Defaults to the configured value.
    # @param [Numeric] connect_timeout - Connection timeout in seconds. Defaults to the configured value.
    # @param [Symbol] adapter - Faraday adapter. Defaults to the configured value (:net_http).
    # @yieldparam [Faraday::Connection] faraday - Customizes this client's connection (middleware,
    #   adapter options...), after the global 'config.connection' block.
    # @return [SteamApiClient::Client] - A new class instance.
    def initialize(api_token: nil, timeout: nil, connect_timeout: nil, adapter: nil, &connection_block)
      @api_token = api_token
      @timeout = timeout
      @connect_timeout = connect_timeout
      @adapter = adapter
      @connection_block = connection_block

      @requestors = Endpoints::ALL.transform_values { |endpoint| Requestor.new(self, endpoint) }
    end

    # The token sent on authorized requests. Falls back to the value set
    # through 'SteamApiClient::Client.configure' when none was given to the instance.
    # @return [String, nil]
    def api_token
      @api_token || config.api_token
    end

    # @return [Numeric] the request timeout in seconds
    def timeout
      @timeout || config.timeout
    end

    # @return [Numeric] the connection timeout in seconds
    def connect_timeout
      @connect_timeout || config.connect_timeout
    end

    # @return [Symbol] the Faraday adapter used for the requests
    def adapter
      @adapter || config.adapter
    end

    # The Faraday connection shared by this client's requests: the adapter, then
    # the global 'config.connection' block, then the block given to Client.new
    # @return [Faraday::Connection]
    def connection
      @connection ||= ::Faraday.new do |faraday|
        faraday.adapter(adapter)
        [config.connection, @connection_block].compact.each { |block| block.call(faraday) }
      end
    end

    def config
      self.class.config
    end

    # Keeps the token out of logs, consoles and error trackers
    # @return [String]
    def inspect
      Configuration.inspect_settings(self)
    end

    def base_endpoint
      BASE_ENDPOINT
    end

    def storefront_endpoint
      STOREFRONT_API_ENDPOINT
    end
  end
end
