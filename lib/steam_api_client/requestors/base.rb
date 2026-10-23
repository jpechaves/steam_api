module SteamApiClient
  module Requestors
    # Class responsible to expose the methods necessary to perform a request
    # on the Steam Web Api.
    # @abstract class for the Requestors
    class Base
      # Initialize the class
      # @param [SteamApiClient::Client] the client object.
      def initialize(client)
        @client = client
      end

      protected

      # Build an Request and executes it
      def build_request_and_run(request_struct_class, response_struct_class, **params)
        request_struct = request_struct_class.build_from_params(params)

        response = build_request(request_struct, response_struct_class).run
        response.result
      end

      attr_accessor :client

      private

      def build_request(request_struct, response_struct_class)
        Request.new(request_struct: request_struct, response_struct: response_struct_class, client: client)
      end
    end
  end
end
