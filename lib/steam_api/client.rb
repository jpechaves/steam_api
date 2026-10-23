# frozen_string_literal: true

module SteamApi
  # Main class to interact with the Steam Api.

  # Before using this client, you need to configure the
  # credentials through the 'SteamApi::Client.configure' method:
  #
  # ```ruby
  # SteamApi::Client.configure do |config|
  #   config.api_token = 'token-value'
  # end
  # ```
  #
  # All API calls take the form:
  # http://api.steampowered.com/<interface name>/<method name>/<version>/?key=<api key>&format=<format>.
  # Format can be any of:
  #   json - The output will be returned in the JSON format
  #   xml - Output is returned as an XML document
  #   vdf - Output is returned as a VDF file.
  # If you do not specify a format, your results will be returns in the JSON format.
  #
  # As we dive deeper into the implementation and find more endpoints to include in this
  # gem, some changes were needed to support the storefront API which is what Steam's
  # Big Picture Mode uses.
  # All API calls take the form:
  # https://store.steampowered.com/api/<method>?appids=1,2,3&filters=basic,recommendations
  # For more information, vist: https://wiki.teamfortress.com/wiki/User:RJackson/StorefrontAPI
  class Client
    extend ::Dry::Configurable

    BASE_ENDPOINT = "https://api.steampowered.com"
    STOREFRONT_API_ENDPOINT = "https://store.steampowered.com/api/"
    DEFAULT_TIMEOUT = 10
    DEFAULT_CONNECT_TIMEOUT = 5

    setting :api_token
    # Maximum time, in seconds, for the whole request
    setting :timeout, default: DEFAULT_TIMEOUT
    # Maximum time, in seconds, to establish the connection
    setting :connect_timeout, default: DEFAULT_CONNECT_TIMEOUT

    attr_writer :api_token, :timeout, :connect_timeout

    attr_reader \
      :app_details,
      :app_global_achievements,
      :app_news,
      :game_current_players,
      :player_achievements,
      :player_friends,
      :player_game_stats,
      :player_level,
      :player_owned_games,
      :player_recent_games,
      :player_steamid,
      :player_summaries

    # Initialize the client
    # @param [String] api_token - An existing api token.
    # @param [Numeric] timeout - Request timeout in seconds. Defaults to the configured value.
    # @param [Numeric] connect_timeout - Connection timeout in seconds. Defaults to the configured value.
    # @return [SteamApi::Client] - A new class instance.
    def initialize(api_token: nil, timeout: nil, connect_timeout: nil)
      @api_token = api_token
      @timeout = timeout
      @connect_timeout = connect_timeout

      @app_details ||= SteamApi::Requestors::AppDetails.new(self)
      @app_global_achievements ||= SteamApi::Requestors::AppGlobalAchievements.new(self)
      @app_news ||= SteamApi::Requestors::AppNews.new(self)
      @game_current_players ||= SteamApi::Requestors::GameCurrentPlayers.new(self)
      @player_achievements ||= SteamApi::Requestors::PlayerAchievements.new(self)
      @player_friends ||= SteamApi::Requestors::PlayerFriends.new(self)
      @player_game_stats ||= SteamApi::Requestors::PlayerGameStats.new(self)
      @player_level ||= SteamApi::Requestors::PlayerLevel.new(self)
      @player_owned_games ||= SteamApi::Requestors::PlayerOwnedGames.new(self)
      @player_recent_games ||= SteamApi::Requestors::PlayerRecentGames.new(self)
      @player_steamid ||= SteamApi::Requestors::PlayerSteamId.new(self)
      @player_summaries ||= SteamApi::Requestors::PlayerSummaries.new(self)
    end

    # The token sent on authorized requests. Falls back to the value set
    # through 'SteamApi::Client.configure' when none was given to the instance.
    # @return [String, nil]
    def api_token
      @api_token || config.api_token
    end

    # @return [Numeric] the request timeout in seconds
    def timeout
      @timeout || config.timeout
    end

    # @return [Numeric] the connection timeout in seconds
    def connect_timeout
      @connect_timeout || config.connect_timeout
    end

    def config
      self.class.config
    end

    def base_endpoint
      BASE_ENDPOINT
    end

    def storefront_endpoint
      STOREFRONT_API_ENDPOINT
    end
  end
end
