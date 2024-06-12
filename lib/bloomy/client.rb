# frozen_string_literal: true

require "faraday"
require_relative "operations/users"
require_relative "operations/todos"
require_relative "operations/rocks"
require_relative "operations/meetings"
require_relative "operations/measurables"
require_relative "operations/issues"

module Bloomy
  # The Client class is the main entry point for interacting with the Bloomy API.
  # It provides methods for managing users, todos, rocks, meetings, measurables, and issues.
  class Client
    attr_reader :configuration, :user, :todo, :rock, :meeting, :measurable, :issue

    # Initializes a new Client instance
    #
    # @example
    #   client = Bloomy::Client.new
    #   client.meetings.list
    #   client.user.details
    #   client.meeting.delete(id)
    def initialize
      @configuration = Configuration.new
      @base_url = "https://app.bloomgrowth.com/api/v1"
      @conn = Faraday.new(url: @base_url) do |faraday|
        faraday.response :json
        faraday.adapter Faraday.default_adapter
        faraday.headers["Accept"] = "*/*"
        faraday.headers["Content-Type"] = "application/json"
        faraday.headers["Authorization"] = "Bearer #{configuration.api_key}"
      end
      @user = User.new(@conn)
      @user_id = @user.default_user_id
      @todo = Todo.new(@conn, @user_id)
      @rock = Rock.new(@conn, @user_id)
      @meeting = Meeting.new(@conn, @user_id)
      @measurable = Measurable.new(@conn, @user_id)
      @issue = Issue.new(@conn, @user_id)
    end
  end
end
