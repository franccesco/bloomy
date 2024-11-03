# frozen_string_literal: true

require "faraday"
require_relative "operations/users"
require_relative "operations/todos"
require_relative "operations/goals"
require_relative "operations/meetings"
require_relative "operations/scorecard"
require_relative "operations/issues"
require_relative "operations/headlines"

module Bloomy
  # The Client class is the main entry point for interacting with the Bloomy API.
  # It provides methods for managing Bloom Growth features.
  class Client
    attr_reader :configuration, :user, :todo, :goal, :meeting, :scorecard, :issue, :headline

    # Initializes a new Client instance
    #
    # @example
    #   client = Bloomy::Client.new
    #   client.meetings.list
    #   client.user.details
    #   client.meeting.delete(id)
    def initialize(api_key = nil)
      @configuration = Configuration.new unless api_key
      @api_key = api_key || @configuration.api_key
      @base_url = "https://app.bloomgrowth.com/api/v1"
      @conn = Faraday.new(url: @base_url) do |faraday|
        faraday.response :json
        faraday.adapter Faraday.default_adapter
        faraday.headers["Accept"] = "*/*"
        faraday.headers["Content-Type"] = "application/json"
        faraday.headers["Authorization"] = "Bearer #{@api_key}"
      end
      @user = User.new(@conn)
      @user_id = @user.default_user_id
      @todo = Todo.new(@conn, @user_id)
      @goal = Goal.new(@conn, @user_id)
      @meeting = Meeting.new(@conn, @user_id)
      @scorecard = Scorecard.new(@conn, @user_id)
      @issue = Issue.new(@conn, @user_id)
      @headline = Headline.new(@conn, @user_id)
    end
  end
end
