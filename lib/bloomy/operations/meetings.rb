# frozen_string_literal: true

# Class to handle all the operations related to meeting
class Meeting
  def initialize(conn, user_id)
    @conn = conn
    @user_id = user_id
  end

  def list(user_id: @user_id)
    response = @conn.get("L10/#{user_id}/list").body
    response.map { |meeting| { id: meeting['Id'], name: meeting['Name'] } }
  end

  def attendees(meeting_id)
    response = @conn.get("L10/#{meeting_id}/attendees").body
    response.map { |attendee| { name: attendee['Name'], id: attendee['Id'] } }
  end

  def issues(meeting_id, include_closed: false)
    response = @conn.get("L10/#{meeting_id}/issues?include_resolved=#{include_closed}").body
    response.map do |issue|
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

  def todos(meeting_id, include_closed: false)
    response = @conn.get("L10/#{meeting_id}/todos?INCLUDE_CLOSED=#{include_closed}").body
    response.map do |todo|
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

  def metrics(meeting_id)
    response = @conn.get("L10/#{meeting_id}/measurables").body
    response.map do |measurable|
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

  def details(meeting_id, include_closed: false)
    meeting = list.find { |m| m[:id] == meeting_id }
    attendees = attendees(meeting_id)
    issues = issues(meeting_id, include_closed: include_closed)
    todos = todos(meeting_id, include_closed: include_closed)
    measurables = metrics(meeting_id)
    {
      id: meeting[:id],
      name: meeting[:name],
      attendees: attendees,
      issues: issues,
      todos: todos,
      metrics: measurables
    }
  end

  def create(title:, add_self: true, attendees: [])
    payload = { title: title, addSelf: add_self }.to_json
    response = @conn.post('L10/create', payload).body
    meeting_id = response['meetingId']
    meeting_details = { meeting_id: meeting_id, title: title }
    attendees.each do |attendee|
      @conn.post("L10/#{meeting_id}/attendees/#{attendee}")
    end
    meeting_details.merge(attendees: attendees)
  end

  def delete(meeting_id)
    @conn.delete("L10/#{meeting_id}")
  end
end
