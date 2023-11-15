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
  end
end
