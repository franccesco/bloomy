require 'json'

module Bloomy
  module MeasurableOperations
    def get_current_week
      response = @conn.get('weeks/current').body
      current_week = {
        id: response['Id'],
        week_number: response['ForWeekNumber'],
        week_start: response['LocalDate']['Date'],
        week_end: response['ForWeek']
      }
    end

    def get_current_scorecards
      response = @conn.get("scorecard/user/mine").body
      current_week = get_current_week[:week_number]

      current_scorecard = response['Scores']
        .select { |scorecard| scorecard['ForWeek'] == current_week }
        .map do |scorecard|
          {
            id: scorecard['Id'],
            title: scorecard['MeasurableName'],
            target: scorecard['Target'],
            value: scorecard['Measured'],
            updated_at: scorecard['DateEntered']
          }
      end
    end

    def update_current_scorecard(scorecard_id, measured)
      response = @conn.put("scores/#{scorecard_id}", { value: measured}.to_json).status
      response == 200
    end
  end
end
