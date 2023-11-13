module Bloomy
  module ClientOperations
    def get_user_details
      response = @conn.get('users/mine').body
    end

    def get_direct_reports
      response = @conn.get('users/minedirectreports').body
      direct_reports = response.map { |report| { name: report['Name'], id: report['Id'] } }
    end
  end
end
