# Real Steam API responses, anonymized and trimmed (see spec/fixtures/steam/README.md)
module SteamFixtures
  DIR = File.expand_path("../fixtures/steam", __dir__)

  def steam_fixture(name)
    File.read(File.join(DIR, "#{name}.json"))
  end

  # Runs a fixture through the gem's response pipeline: status handling, then struct parsing
  def parse_steam_fixture(name, struct, status: 200)
    raw = Typhoeus::Response.new(code: status, body: steam_fixture(name), return_code: :ok)
    response = SteamApiClient::Response.new(raw_response: raw, response_struct: struct, request: nil)
    SteamApiClient::FailureHandler.instance.call(response)
    response.result
  end
end
