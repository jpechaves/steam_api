module SteamApiClient
  module Errors
    # Raised when Steam can't be reached at all (DNS failure, refused connection,
    # TLS error), so there is no HTTP response. The adapter's error is #cause.
    class ConnectionError < ::StandardError; end
  end
end
