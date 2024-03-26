module Bloomy
  module UserOperations
    def get_user_details(user_id: get_my_user_id, direct_reports: false, positions: false, all: false)
      response = @conn.get("users/#{user_id}").body
      user_details = { name: response['Name'], id: response['Id'], image_url: response['ImageUrl'] }

      user_details[:direct_reports] = get_direct_reports(user_id) if direct_reports || all
      user_details[:positions] = get_positions(user_id) if positions || all

      user_details
    end

    def get_direct_reports(user_id)
      direct_reports_response = @conn.get("users/#{user_id}/directreports").body
      direct_reports_response.map { |report| { name: report['Name'], id: report['Id'], image_url: report['ImageUrl'] } }
    end

    def get_positions(user_id)
      position_response = @conn.get("users/#{user_id}/seats").body
      position_response.map { |position| { name: position['Group']['Position']['Name'], id: position['Group']['Position']['Id'] } }
    end

    def get_my_user_id
      response = @conn.get('users/mine').body
      response['Id']
    end

    def search_users(term)
      response = @conn.get('search/user', term: term).body
      response.map do |user|
        {
          id: user['Id'],
          name: user['Name'],
          description: user['Description'],
          email: user['Email'],
          organization_id: user['OrganizationId'],
          image_url: user['ImageUrl']
        }
      end
    end
  end
end
