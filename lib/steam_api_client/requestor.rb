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
    # @return [SteamApiClient::Structs::Base] the endpoint's response struct
    # @raise [ArgumentError] on missing, unknown or invalid arguments
    def retrieve(**params)
      Request.new(endpoint: endpoint, params: params, client: client).run.result
    end

    # Keeps the client (and its token) out of the output
    # @return [String]
    def inspect
      "#<#{self.class.name} #{endpoint.name} #{endpoint.path}>"
    end

    private

    attr_reader :client
  end
end
