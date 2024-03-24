module Bloomy
  module UserOperations
    def get_user_details(user_id)
      response = @conn.get("users/#{user_id}").body
      user_details = { name: response['Name'], id: response['Id'], image_url: response['ImageUrl'] }
    end
      response = @conn.get('users/mine').body
    end

    def get_direct_reports
      response = @conn.get('users/minedirectreports').body
      direct_reports = response.map { |report| { name: report['Name'], id: report['Id'] } }
    end
  end
end
