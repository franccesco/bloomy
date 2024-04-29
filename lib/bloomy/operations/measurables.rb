# frozen_string_literal: true

require 'json'

module Bloomy
  module MeasurableOperations
    def get_current_week
      response = @conn.get('weeks/current').body
      {
        id: response['Id'],
        week_number: response['ForWeekNumber'],
        week_start: response['LocalDate']['Date'],
        week_end: response['ForWeek']
      }
    end

    def get_my_scorecards(current_week_only = true, show_empty = true)
      response = @conn.get('scorecard/user/mine').body
      scorecards = response['Scores'].map do |scorecard|
        {
          id: scorecard['Id'],
          title: scorecard['MeasurableName'],
          target: scorecard['Target'],
          value: scorecard['Measured'],
          updated_at: scorecard['DateEntered'],
          week_number: scorecard['ForWeek']
        }
      end

      if current_week_only
        current_week = get_current_week[:week_number]
        scorecards.select do |scorecard|
          scorecard[:week_number] == current_week && (show_empty || scorecard[:value].nil?)
        end
      else
        scorecards.select { |scorecard| show_empty || scorecard[:value].nil? }
      end
    end

    def update_current_scorecard(scorecard_id, measured)
      response = @conn.put("scores/#{scorecard_id}", { value: measured }.to_json).status
      response == 200
    end
  end
end
