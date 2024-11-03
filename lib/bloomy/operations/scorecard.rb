# frozen_string_literal: true

require "json"

# Class to handle all the operations related to scorecards
# @note
#   This class is already initialized via the client and usable as `client.scorecard.method`
class Scorecard
  # Initializes a new Scorecard instance
  #
  # @param conn [Object] the connection object to interact with the API
  # @param user_id [Integer] the ID of the user
  def initialize(conn, user_id)
    @conn = conn
    @user_id = user_id
  end

  # Retrieves the current week details
  #
  # @return [Hash] a hash containing current week details
  # @example
  #   client.scorecard.current_week
  #   #=> { id: 123, week_number: 24, week_start: "2024-06-10", week_end: "2024-06-16" }
  def current_week
    response = @conn.get("weeks/current").body
    {
      id: response["Id"],
      week_number: response["ForWeekNumber"],
      week_start: response["LocalDate"]["Date"],
      week_end: response["ForWeek"]
    }
  end

  # Retrieves the scorecards for a user or a meeting.
  #
  # @param user_id [Integer, nil] the ID of the user (defaults to initialized user_id)
  # @param meeting_id [Integer, nil] the ID of the meeting
  # @param show_empty [Boolean] whether to include scores with nil values (default: false)
  # @param week_offset [Integer, nil] offset for the week number to filter scores
  # @raise [ArgumentError] if both `user_id` and `meeting_id` are provided
  # @return [Array<Hash>] an array of hashes containing scorecard details
  # @example
  #   # Fetch scorecards for the current user
  #   client.scorecard.list
  #
  #   # Fetch scorecards for a specific user
  #   client.scorecard.list(user_id: 42)
  #
  #   # Fetch scorecards for a specific meeting
  #   client.scorecard.list(meeting_id: 99)
  def list(user_id: nil, meeting_id: nil, show_empty: false, week_offset: nil)
    if user_id && meeting_id
      raise ArgumentError, "Please provide either `user_id` or `meeting_id`, not both."
    end

    if meeting_id
      response = @conn.get("scorecard/meeting/#{meeting_id}").body
    else
      user_id ||= @user_id
      response = @conn.get("scorecard/user/#{user_id}").body
    end

    scorecards = response["Scores"].map do |scorecard|
      {
        id: scorecard["Id"],
        measurable_id: scorecard["MeasurableId"],
        accountable_user_id: scorecard["AccountableUserId"],
        title: scorecard["MeasurableName"],
        target: scorecard["Target"],
        value: scorecard["Measured"],
        week: scorecard["Week"],
        updated_at: scorecard["DateEntered"]
      }
    end

    if week_offset
      week_data = current_week
      week_id = week_data[:week_number] - week_offset
      scorecards.select! { |scorecard| scorecard[:week] == week_id }
    end

    scorecards.select! { |scorecard| scorecard[:value] || show_empty } unless show_empty
    scorecards
  end

  # Updates a scorecard with a new measured value
  #
  # @param scorecard_id [Integer] the ID of the scorecard to update
  # @param measured [Numeric] the new measured value
  # @return [Boolean] true if the operation was successful, false otherwise
  # @example
  #   client.scorecard.update(1, 85)
  #   #=> true
  def update(scorecard_id, measured)
    response = @conn.put("scores/#{scorecard_id}", {value: measured}.to_json).status
    response == 200
  end
end
