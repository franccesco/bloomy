# frozen_string_literal: true

require "faraday"
require "faraday/retry"

require "bloomy/operations/users"
require "bloomy/operations/todos"
require "bloomy/operations/goals"
require "bloomy/operations/meetings"
require "bloomy/operations/scorecard"
require "bloomy/operations/issues"
require "bloomy/operations/headlines"

module Bloomy
  # The Client class is the main entry point for interacting with the Bloomy API.
  # It provides methods for managing Bloom Growth features.
  class Client
    # Default retry options for transient failures
    DEFAULT_RETRY_OPTIONS = {
      max: 3,
      interval: 0.5,
      interval_randomness: 0.5,
      backoff_factor: 2,
      retry_statuses: [429, 502, 503, 504],
      exceptions: [Faraday::TimeoutError, Faraday::ConnectionFailed]
    }.freeze

    attr_reader :configuration, :user, :todo, :goal, :meeting, :scorecard, :issue, :headline

    # Returns the current user's ID
    #
    # @return [Integer] the current user's ID
    # @example
    #   client.user_id
    #   #=> 12345
    def user_id
      @user_id ||= @user.user_id
    end

    # Initializes a new Client instance
    #
    # @param api_key [String, nil] API key for authentication (optional if configured elsewhere)
    # @param open_timeout [Integer] connection timeout in seconds (default: 10)
    # @param read_timeout [Integer] read timeout in seconds (default: 30)
    # @param retry_options [Hash] custom retry options to merge with defaults
    # @raise [ArgumentError] if no API key is provided or configured
    # @example Basic usage
    #   client = Bloomy::Client.new
    #   client.meeting.list
    #
    # @example With custom timeouts
    #   client = Bloomy::Client.new(open_timeout: 5, read_timeout: 60)
    #
    # @example With custom retry options
    #   client = Bloomy::Client.new(retry_options: { max: 5 })
    def initialize(api_key = nil, open_timeout: 10, read_timeout: 30, retry_options: {})
      @configuration = Configuration.new unless api_key
      @api_key = api_key || @configuration.api_key

      raise ArgumentError, "No API key provided. Set it in configuration or pass it directly." unless @api_key

      @base_url = "https://app.bloomgrowth.com/api/v1/"
      merged_retry_options = DEFAULT_RETRY_OPTIONS.merge(retry_options)

      @conn = Faraday.new(url: @base_url) do |faraday|
        faraday.request :retry, merged_retry_options
        faraday.response :json
        faraday.adapter Faraday.default_adapter
        faraday.headers["Accept"] = "*/*"
        faraday.headers["Content-Type"] = "application/json"
        faraday.headers["Authorization"] = "Bearer #{@api_key}"
        faraday.options.open_timeout = open_timeout
        faraday.options.timeout = read_timeout
      end

      @user = User.new(@conn)
      @todo = Todo.new(@conn)
      @goal = Goal.new(@conn)
      @meeting = Meeting.new(@conn)
      @scorecard = Scorecard.new(@conn)
      @issue = Issue.new(@conn)
      @headline = Headline.new(@conn)
    end
  end
end
