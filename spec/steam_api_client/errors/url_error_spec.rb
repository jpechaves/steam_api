require "spec_helper"

RSpec.describe SteamApiClient::Errors::EndpointKindNotSupported do
  let(:request_struct) { double("RequestStruct") }

  subject(:request) do
    SteamApiClient::Request.new(
      request_struct: request_struct,
      response_struct: double("ResponseStruct"),
      client: double("Client")
    )
  end

  describe "when the endpoint kind for the request is invalid" do
    before do
      allow(request_struct).to receive(:endpoint_kind).and_return(:unsupported_endpoint)
    end

    it "raises an error for unsupported endpoint kind" do
      expect { request.send(:build_request) }.to raise_error(SteamApiClient::Errors::EndpointKindNotSupported)
    end
  end
end
