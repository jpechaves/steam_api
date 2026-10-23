require "spec_helper"

RSpec.describe SteamApiClient::FailureHandler do
  subject { described_class.instance.call(response) }

  shared_examples "validate exception class and error message" do
    it "has a description message with status code and body" do
      expect { subject }.to raise_error(
        exception,
        /A request failed with the following status code: #{status_code} and body: #{body}/
      )
    end
  end

  let(:response) do
    double(
      "response",
      fail?: failed,
      body: body,
      request: request,
      status_code: status_code
    )
  end
  let(:request) { double("request") }
  let(:failed) { true }
  let(:status_code) { 200 }
  let(:body) { "{}" }

  describe "#call" do
    context "when the response is a successful" do
      let(:failed) { false }

      it { is_expected.to eql(nil) }
    end

    context "when Steam answers 408 Request Timeout" do
      let(:exception) { SteamApiClient::Errors::HttpTimeout }
      let(:status_code) { 408 }
      let(:body) { '{response: "A timeout ocurred!"}' }

      it_behaves_like "validate exception class and error message"
    end

    context "when the request status code is not mapped with a specific exception" do
      let(:exception) { SteamApiClient::Errors::ApiError }
      let(:status_code) { 523 }
      let(:body) { '{response: "An unmapped error code"}' }

      it_behaves_like "validate exception class and error message"
    end

    context "when the request status code is an unmapped 4xx error" do
      let(:exception) { SteamApiClient::Errors::ApiError }
      let(:status_code) { 418 }
      let(:body) { '{response: "I am a teapot"}' }

      it_behaves_like "validate exception class and error message"
    end

    context "when the request fails with a status code outside 4xx/5xx" do
      let(:exception) { SteamApiClient::Errors::ApiError }
      let(:status_code) { 302 }
      let(:body) { "Moved" }

      it_behaves_like "validate exception class and error message"
    end

    context "when the request status code is a mapped 4xx error" do
      context "when the status code is 400" do
        let(:exception) { SteamApiClient::Errors::HttpBadRequest }
        let(:status_code) { 400 }
        let(:body) { '{response: "400 bad request"}' }

        it_behaves_like "validate exception class and error message"
      end

      context "when the status code is 401" do
        let(:exception) { SteamApiClient::Errors::HttpUnauthorized }
        let(:status_code) { 401 }
        let(:body) { '{response: "401 unauthorized"}' }

        it_behaves_like "validate exception class and error message"
      end

      context "when the status code is 403" do
        let(:exception) { SteamApiClient::Errors::HttpForbidden }
        let(:status_code) { 403 }
        let(:body) { '{response: "403 forbidden"}' }

        it_behaves_like "validate exception class and error message"
      end

      context "when the status code is 404" do
        let(:exception) { SteamApiClient::Errors::HttpNotFound }
        let(:status_code) { 404 }
        let(:body) { '{response: "404 not_found"}' }

        it_behaves_like "validate exception class and error message"
      end
    end

    context "when the request is rate limited (429)" do
      let(:exception) { SteamApiClient::Errors::HttpTooManyRequests }
      let(:status_code) { 429 }
      let(:body) { "Too Many Requests" }

      it_behaves_like "validate exception class and error message"
    end

    context "when the request status code is 502" do
      let(:exception) { SteamApiClient::Errors::HttpBadGateway }
      let(:status_code) { 502 }
      let(:body) { "Bad Gateway" }

      it_behaves_like "validate exception class and error message"
    end

    context "when the request status code is 503" do
      let(:exception) { SteamApiClient::Errors::HttpServiceUnavailable }
      let(:status_code) { 503 }
      let(:body) { "Service Unavailable" }

      it_behaves_like "validate exception class and error message"
    end

    context "when the request status code is a mapped 5xx error" do
      context "when the status code is 500" do
        let(:exception) { SteamApiClient::Errors::HttpInternalServerError }
        let(:status_code) { 500 }
        let(:body) { '{response: "500 bad_request"}' }

        it_behaves_like "validate exception class and error message"
      end
    end
  end
end
