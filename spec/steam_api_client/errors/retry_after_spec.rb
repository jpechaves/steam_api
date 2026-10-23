require "spec_helper"

RSpec.describe "Retry-After on rate limit and unavailable errors" do
  let(:response) { double(:response, status_code: 429, request: nil, body: "slow down", headers: headers) }
  let(:headers) { {} }

  [SteamApiClient::Errors::HttpTooManyRequests, SteamApiClient::Errors::HttpServiceUnavailable].each do |error_class|
    describe error_class do
      subject(:error) { error_class.new(response) }

      it { is_expected.to be_a(SteamApiClient::Errors::ApiError) }

      context "when Retry-After is a number of seconds" do
        let(:headers) { {"Retry-After" => "120"} }

        it { expect(error.retry_after).to eq(120) }
      end

      context "when Retry-After is an HTTP date" do
        let(:headers) { {"Retry-After" => (Time.now + 30).httpdate} }

        it "returns the seconds until that date" do
          expect(error.retry_after).to be_within(2).of(30)
        end
      end

      context "when Retry-After is in the past" do
        let(:headers) { {"Retry-After" => (Time.now - 30).httpdate} }

        it { expect(error.retry_after).to eq(0) }
      end

      [{}, {"Retry-After" => "soon"}, nil].each do |value|
        context "when the headers are #{value.inspect}" do
          let(:headers) { value }

          it { expect(error.retry_after).to be_nil }
        end
      end
    end
  end

  it "reads the header from a Typhoeus response through SteamApiClient::Response" do
    raw = Typhoeus::Response.new(code: 429, body: "slow down", response_headers: "HTTP/1.1 429 Too Many Requests\r\nRetry-After: 7\r\n\r\n")
    response = SteamApiClient::Response.new(raw_response: raw, response_struct: nil, request: nil)

    expect(SteamApiClient::Errors::HttpTooManyRequests.new(response).retry_after).to eq(7)
  end
end
