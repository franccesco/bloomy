module Bloomy
  module MeetingOperations
  include Bloomy::UserOperations
    def get_meetings(user_id: get_my_user_id)
      response = @conn.get("L10/#{user_id}/list").body
      meetings = response.map { |meeting| { id: meeting['Id'], name: meeting['Name'] } }
    end

    def get_meeting_attendees(meeting_id)
      response = @conn.get("L10/#{meeting_id}/attendees").body
      attendees = response.map { |attendee| { name: attendee['Name'], id: attendee['Id'] } }
    end

    def get_meeting_issues(meeting_id, include_closed: false)
      response = @conn.get("L10/#{meeting_id}/issues?include_resolved=#{include_closed}").body
      issues = response.map do |issue|
        {
          id: issue['Id'],
          title: issue['Name'],
          created_at: issue['CreateTime'],
          closed_at: issue['CloseTime'],
          details_url: issue['DetailsUrl'],
          owner: {
            id: issue['Owner']['Id'],
            name: issue['Owner']['Name']
          }
        }
      end
    end
  end
end
