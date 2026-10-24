module SteamApiClient
  # What the client exposes for each endpoint, e.g. `client.player_level`
  class Requestor
    attr_reader :endpoint

    # @param [SteamApiClient::Client] client
    # @param [SteamApiClient::Endpoint] endpoint
    def initialize(client, endpoint)
      @client = client
      @endpoint = endpoint
    end

    # Calls the endpoint. The keyword arguments are the endpoint's params
    # (see SteamApiClient::Endpoints).
    # @return [Data, Array, Integer, nil] the endpoint's result
    # @raise [ArgumentError] on missing, unknown or invalid arguments
    def retrieve(**params)
      run(params).result
    end

    # Calls the endpoint and returns Steam's JSON untouched (keys symbolized), e.g.
    # for fields the result doesn't have
    # @return [Hash]
    def retrieve_raw(**params)
      run(params).json
    end

    # Keeps the client (and its token) out of the output
    # @return [String]
    def inspect
      "#<#{self.class.name} #{endpoint.name} #{endpoint.path}>"
    end

    private

    attr_reader :client

    def run(params)
      Request.new(endpoint: endpoint, params: params, client: client).run
    end
  end
end
