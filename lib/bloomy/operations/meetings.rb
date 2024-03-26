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

    def get_meeting_todos(meeting_id, include_closed: false)
      response = @conn.get("L10/#{meeting_id}/todos?INCLUDE_CLOSED=#{include_closed}").body
      todos = response.map do |todo|
        {
          id: todo['Id'],
          title: todo['Name'],
          due_date: todo['DueDate'],
          details_url: todo['DetailsUrl'],
          completed_at: todo['CompleteTime'],
          owner: {
            id: todo['Owner']['Id'],
            name: todo['Owner']['Name']
          }
        }
      end
    end

    def get_meeting_measurables(meeting_id)
      response = @conn.get("L10/#{meeting_id}/measurables").body
      measurables = response.map do |measurable|
        {
          id: measurable['Id'],
          name: measurable['Name'].strip,
          target: measurable['Target'],
          operator: measurable['Direction'],
          format: measurable['Modifiers'],
          owner: {
            id: measurable['Owner']['Id'],
            name: measurable['Owner']['Name']
          },
          admin: {
            id: measurable['Admin']['Id'],
            name: measurable['Admin']['Name']
          }
        }
      end
    end
  end
end
