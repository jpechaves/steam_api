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
    end

    # @return [Hash]
    def to_h
      {api_token: api_token, timeout: timeout, connect_timeout: connect_timeout, adapter: adapter}
    end

    # Keeps the token out of logs, consoles and error trackers
    # @return [String]
    def inspect
      token = api_token.nil? ? "nil" : "[REDACTED]"
      "#<#{self.class.name} api_token=#{token} timeout=#{timeout} connect_timeout=#{connect_timeout} adapter=#{adapter.inspect}>"
    end
  end
end
