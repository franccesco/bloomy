# frozen_string_literal: true

require "json"

# Class to handle all the operations related to measurables
class Measurable
  def initialize(conn, user_id)
    @conn = conn
    @user_id = user_id
  end

  def current_week
    response = @conn.get("weeks/current").body
    {
      id: response["Id"],
      week_number: response["ForWeekNumber"],
      week_start: response["LocalDate"]["Date"],
      week_end: response["ForWeek"]
    }
  end

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

  def update(scorecard_id, measured)
    response = @conn.put("scores/#{scorecard_id}", {value: measured}.to_json).status
    response == 200
  end
end
