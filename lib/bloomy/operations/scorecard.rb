# frozen_string_literal: true

require "json"
require "bloomy/utils/get_user_id"

module Bloomy
  # Class to handle all the operations related to scorecards
  # @note
  #   This class is already initialized via the client and usable as `client.scorecard.method`
  class Scorecard
    include Bloomy::Utilities::UserIdUtility
    include Bloomy::Utilities::Transform

    # Initializes a new Scorecard instance
    #
    # @param conn [Object] the connection object to interact with the API
    def initialize(conn)
      @conn = conn
    end

    # Retrieves the current week details
    #
    # @return [HashWithIndifferentAccess] a hash containing current week details
    # @raise [ApiError] when the API request fails
    # @example
    #   client.scorecard.current_week
    #   #=> { id: 123, week_number: 24, week_start: "2024-06-10", week_end: "2024-06-16" }
    def current_week
      response = @conn.get("weeks/current")
      data = handle_response(response, context: "get current week")

      transform_response({
        id: data.dig("Id"),
        week_number: data.dig("ForWeekNumber"),
        week_start: data.dig("LocalDate", "Date"),
        week_end: data.dig("ForWeek")
      })
    end

    # Retrieves the scorecards for a user or a meeting.
    #
    # @param user_id [Integer, nil] the ID of the user (defaults to initialized user_id)
    # @param meeting_id [Integer, nil] the ID of the meeting
    # @param show_empty [Boolean] whether to include scores with nil values (default: false)
    # @param week_offset [Integer, nil] offset for the week number to filter scores
    # @raise [ArgumentError] if both `user_id` and `meeting_id` are provided
    # @raise [NotFoundError] when user or meeting is not found
    # @raise [ApiError] when the API request fails
    # @return [Array<HashWithIndifferentAccess>] an array of scorecard hashes
    # @example
    #   # Fetch scorecards for the current user
    #   client.scorecard.list
    #
    #   # Fetch scorecards for a specific user
    #   client.scorecard.list(user_id: 42)
    #
    #   # Fetch scorecards for a specific meeting
    #   client.scorecard.list(meeting_id: 99)
    # @note
    #  The `week_offset` parameter is useful when fetching scores for previous or future weeks.
    #  For example, to fetch scores for the previous week, you can set `week_offset` to -1.
    #  To fetch scores for a future week, you can set `week_offset` to a positive value.
    def list(user_id: nil, meeting_id: nil, show_empty: false, week_offset: nil)
      raise ArgumentError, "Please provide either `user_id` or `meeting_id`, not both." if user_id && meeting_id

      if meeting_id
        response = @conn.get("scorecard/meeting/#{meeting_id}")
        data = handle_response(response, context: "get meeting scorecard")
      else
        user_id ||= self.user_id
        response = @conn.get("scorecard/user/#{user_id}")
        data = handle_response(response, context: "get user scorecard")
      end

      scorecards = transform_array((data.dig("Scores") || []).map do |scorecard|
        {
          id: scorecard.dig("Id"),
          measurable_id: scorecard.dig("MeasurableId"),
          accountable_user_id: scorecard.dig("AccountableUserId"),
          title: scorecard.dig("MeasurableName"),
          target: scorecard.dig("Target"),
          value: scorecard.dig("Measured"),
          week: scorecard.dig("Week"),
          week_id: scorecard.dig("ForWeek"),
          updated_at: scorecard.dig("DateEntered")
        }
      end)

      if week_offset
        week_data = current_week
        week_id = week_data[:week_number] + week_offset
        scorecards.select! { |scorecard| scorecard[:week_id] == week_id }
      end

      scorecards.reject! { |scorecard| scorecard[:value].nil? } unless show_empty
      scorecards
    end

    # Retrieves a single scorecard item by measurable ID
    #
    # @param measurable_id [Integer] the ID of the measurable item
    # @param user_id [Integer, nil] the ID of the user (defaults to initialized user_id)
    # @param week_offset [Integer] offset for the week number to filter scores (default: 0)
    # @return [HashWithIndifferentAccess, nil] the scorecard hash if found, nil otherwise
    # @raise [NotFoundError] when user is not found
    # @raise [ApiError] when the API request fails
    # @example
    #   client.scorecard.get(measurable_id: 123)
    #   #=> { id: 1, measurable_id: 123, title: "Sales", target: 100, value: 95, ... }
    def get(measurable_id:, user_id: nil, week_offset: 0)
      scorecards = list(user_id: user_id, show_empty: true, week_offset: week_offset)
      scorecards.find { |s| s[:measurable_id] == measurable_id }
    end

    # Updates the score for a measurable item for a specific week.
    #
    # @param measurable_id [Integer] the ID of the measurable item
    # @param score [Numeric] the score to be assigned to the measurable item
    # @param week_offset [Integer] the number of weeks to offset from the current week (default: 0)
    # @return [Boolean] true if the score was successfully updated
    # @raise [NotFoundError] when measurable is not found
    # @raise [ApiError] when the API request fails
    # @example
    #   client.scorecard.score(measurable_id: 123, score: 5)
    #   #=> true
    def score(measurable_id:, score:, week_offset: 0)
      week_data = current_week
      week_id = week_data[:week_number] + week_offset

      response = @conn.put("measurables/#{measurable_id}/week/#{week_id}", {value: score}.to_json)
      handle_response!(response, context: "update scorecard score")
    end
  end
end
