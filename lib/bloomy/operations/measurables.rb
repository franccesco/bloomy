# frozen_string_literal: true

require "json"

# Class to handle all the operations related to measurables
# @note
#   This class is already initialized via the client and usable as `client.measurable.method`
class Measurable
  # Initializes a new Measurable instance
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
  #   client.measurable.current_week
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

  # Retrieves the scorecard for the user
  #
  # @param current_week_only [Boolean] whether to include only the current week's scores (default: true)
  # @param show_empty [Boolean] whether to include scores with nil values (default: true)
  # @return [Array<Hash>] an array of hashes containing scorecard details
  # @example
  #   client.measurable.scorecard
  #   #=> [{ id: 123, title: "Sales", target: 100, value: 80, updated_at: "2024-06-12", week_number: 24 }, ...]
  def scorecard(current_week_only: true, show_empty: true)
    response = @conn.get("scorecard/user/mine").body
    scorecards = response["Scores"].map do |scorecard|
      {
        id: scorecard["Id"],
        title: scorecard["MeasurableName"],
        target: scorecard["Target"],
        value: scorecard["Measured"],
        updated_at: scorecard["DateEntered"],
        week_number: scorecard["ForWeek"]
      }
    end

    if current_week_only
      week_id = current_week[:week_number]
      scorecards.select do |scorecard|
        scorecard[:week_number] == week_id && (show_empty || scorecard[:value].nil?)
      end
    else
      scorecards.select { |scorecard| show_empty || scorecard[:value].nil? }
    end
  end

  # Updates a scorecard with a new measured value
  #
  # @param scorecard_id [Integer] the ID of the scorecard to update
  # @param measured [Numeric] the new measured value
  # @return [Boolean] true if the operation was successful, false otherwise
  # @example
  #   client.measurable.update(1, 85)
  #   #=> true
  def update(scorecard_id, measured)
    response = @conn.put("scores/#{scorecard_id}", {value: measured}.to_json).status
    response == 200
  end
end
