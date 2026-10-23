require "spec_helper"

RSpec.describe SteamApiClient::Errors::ApiError do
  let(:response) do
    double(
      :response,
      status_code: 100,
      request: {}.to_json,
      body: {message: "error"}.to_json
    )
  end

  subject { described_class.new(response) }

  describe "#initialize" do
    let(:expected_message) do
      <<-MESSAGE.split.join(" ")
        A request failed with the following status code: 100
        and body: {"message":"error"}
      MESSAGE
    end

    it "builds the error message with the response body content" do
      expect(subject.message).to eql(expected_message)
      expect(subject.class).to eq(SteamApiClient::Errors::ApiError)
    end
  end
end
