module SteamApiClient
  # Global defaults for every Client, set with 'SteamApiClient::Client.configure'.
  # Values given to Client.new override them.
  class Configuration
    DEFAULT_TIMEOUT = 10
    DEFAULT_CONNECT_TIMEOUT = 5
    DEFAULT_ADAPTER = :net_http

    # Steam Web API token, sent on the endpoints that need one
    attr_accessor :api_token
    # Maximum time, in seconds, for the whole request
    attr_accessor :timeout
    # Maximum time, in seconds, to establish the connection
    attr_accessor :connect_timeout
    # Faraday adapter used for the requests, e.g. :net_http (default) or any
    # adapter gem the app installs
    attr_accessor :adapter

    def initialize
      @api_token = nil
      @timeout = DEFAULT_TIMEOUT
      @connect_timeout = DEFAULT_CONNECT_TIMEOUT
      @adapter = DEFAULT_ADAPTER
      @connection = nil
    end

    # Customizes the Faraday connection of every client (middleware, adapter
    # options...). It runs after the adapter is set, so it can replace it.
    #   config.connection { |faraday| faraday.request :retry }
    # @yieldparam [Faraday::Connection] faraday
    # @return [Proc, nil] the block, when called without one
    def connection(&block)
      block ? @connection = block : @connection
    end

    # @return [Hash]
    def to_h
      {api_token: api_token, timeout: timeout, connect_timeout: connect_timeout, adapter: adapter}
    end

    # Keeps the token out of logs, consoles and error trackers
    # @return [String]
    def inspect
      self.class.inspect_settings(self)
    end

    # The settings of a Configuration or a Client, with the token redacted
    # @return [String]
    def self.inspect_settings(object)
      token = object.api_token.nil? ? "nil" : "[REDACTED]"
      settings = "timeout=#{object.timeout} connect_timeout=#{object.connect_timeout} adapter=#{object.adapter.inspect}"
      "#<#{object.class.name} api_token=#{token} #{settings}>"
    end
  end
end
