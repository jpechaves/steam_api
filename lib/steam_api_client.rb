# frozen_string_literal: true

require "json"
require "time"
require "singleton"
require "faraday"

require_relative "steam_api_client/version"
require_relative "steam_api_client/configuration"
require_relative "steam_api_client/model"
require_relative "steam_api_client/model/scalars"
require_relative "steam_api_client/model/field"
require_relative "steam_api_client/endpoint"
require_relative "steam_api_client/endpoint/param"
require_relative "steam_api_client/request"
require_relative "steam_api_client/requestor"
require_relative "steam_api_client/response"
require_relative "steam_api_client/failure_handler"

require_relative "steam_api_client/errors/api_error"
require_relative "steam_api_client/errors/connection_error"
require_relative "steam_api_client/errors/missing_api_token"
require_relative "steam_api_client/errors/response_parse_error"

require_relative "steam_api_client/models/player_summary"
require_relative "steam_api_client/models/friend"
require_relative "steam_api_client/models/game"
require_relative "steam_api_client/models/player_achievements"
require_relative "steam_api_client/models/player_game_stats"
require_relative "steam_api_client/models/news_item"
require_relative "steam_api_client/models/global_achievement"
require_relative "steam_api_client/models/app_details"
require_relative "steam_api_client/models/wishlist_item"

require_relative "steam_api_client/endpoints"
require_relative "steam_api_client/client"

# Main module
module SteamApiClient; end
