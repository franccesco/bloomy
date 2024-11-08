# frozen_string_literal: true

require "bloomy/utils/get_user_id"

# Class to handle all the operations related to meeting
# @note
#   This class is already initialized via the client and usable as `client.measurable.method`
class Meeting
  include Bloomy::Utilities::UserIdUtility
  # Initializes a new Meeting instance
  #
  # @param conn [Object] the connection object to interact with the API
  def initialize(conn)
    @conn = conn
  end

  # Lists all meetings for a specific user
  #
  # @param user_id [Integer] the ID of the user (default is the initialized user ID)
  # @return [Array<Hash>] an array of hashes containing meeting details
  # @example
  #   client.meeting.list
  #   #=> [{ id: 123, name: "Team Meeting" }, ...]
  def list(user_id = self.user_id)
    response = @conn.get("L10/#{user_id}/list").body
    response.map { |meeting| {id: meeting["Id"], name: meeting["Name"]} }
  end

  # Lists all attendees for a specific meeting
  #
  # @param meeting_id [Integer] the ID of the meeting
  # @return [Array<Hash>] an array of hashes containing attendee details
  # @example
  #   client.meeting.attendees(1)
  #   #=> [{ name: "John Doe", id: 1 }, ...]
  def attendees(meeting_id)
    response = @conn.get("L10/#{meeting_id}/attendees").body
    response.map { |attendee| {name: attendee["Name"], id: attendee["Id"]} }
  end

  # Lists all issues for a specific meeting
  #
  # @param meeting_id [Integer] the ID of the meeting
  # @param include_closed [Boolean] whether to include closed issues (default: false)
  # @return [Array<Hash>] an array of hashes containing issue details
  # @example
  #   client.meeting.issues(1)
  #   #=> [{ id: 1, title: "Issue Title", created_at: "2024-06-10", ... }, ...]
  def issues(meeting_id, include_closed: false)
    response = @conn.get("L10/#{meeting_id}/issues?include_resolved=#{include_closed}").body
    response.map do |issue|
      {
        id: issue["Id"],
        title: issue["Name"],
        created_at: issue["CreateTime"],
        closed_at: issue["CloseTime"],
        details_url: issue["DetailsUrl"],
        owner: {
          id: issue["Owner"]["Id"],
          name: issue["Owner"]["Name"]
        }
      }
    end
  end

  # Lists all todos for a specific meeting
  #
  # @param meeting_id [Integer] the ID of the meeting
  # @param include_closed [Boolean] whether to include closed todos (default: false)
  # @return [Array<Hash>] an array of hashes containing todo details
  # @example
  #   client.meeting.todos(1)
  #   #=> [{ id: 1, title: "Todo Title", due_date: "2024-06-12", ... }, ...]
  def todos(meeting_id, include_closed: false)
    response = @conn.get("L10/#{meeting_id}/todos?INCLUDE_CLOSED=#{include_closed}").body
    response.map do |todo|
      {
        id: todo["Id"],
        title: todo["Name"],
        due_date: todo["DueDate"],
        details_url: todo["DetailsUrl"],
        completed_at: todo["CompleteTime"],
        owner: {
          id: todo["Owner"]["Id"],
          name: todo["Owner"]["Name"]
        }
      }
    end
  end

  # Lists all metrics for a specific meeting
  #
  # @param meeting_id [Integer] the ID of the meeting
  # @return [Array<Hash>] an array of hashes containing metric details
  # @example
  #   client.meeting.metrics(1)
  #   #=> [{ id: 1, name: "Sales", target: 100, operator: ">", format: "currency", ... }, ...]
  def metrics(meeting_id)
    response = @conn.get("L10/#{meeting_id}/measurables").body
    response.map do |measurable|
      {
        id: measurable["Id"],
        name: measurable["Name"].strip,
        target: measurable["Target"],
        operator: measurable["Direction"],
        format: measurable["Modifiers"],
        owner: {
          id: measurable["Owner"]["Id"],
          name: measurable["Owner"]["Name"]
        },
        admin: {
          id: measurable["Admin"]["Id"],
          name: measurable["Admin"]["Name"]
        }
      }
    end
  end

  # Retrieves details of a specific meeting
  #
  # @param meeting_id [Integer] the ID of the meeting
  # @param include_closed [Boolean] whether to include closed issues and todos (default: false)
  # @return [Hash] a hash containing detailed information about the meeting
  # @example
  #   client.meeting.details(1)
  #   #=> { id: 1, name: "Team Meeting", attendees: [...], issues: [...], todos: [...], metrics: [...] }
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

  # Creates a new meeting
  #
  # @param title [String] the title of the new meeting
  # @param add_self [Boolean] whether to add the current user as an attendee (default: true)
  # @param attendees [Array<Integer>] a list of user IDs to add as attendees
  # @return [Hash] a hash containing the new meeting's ID and title, and the list of attendees
  # @example
  #   client.meeting.create(title: "New Meeting", attendees: [2, 3])
  #   #=> { meeting_id: 1, title: "New Meeting", attendees: [2, 3] }
  def create(title, add_self: true, attendees: [])
    payload = {title: title, addSelf: add_self}.to_json
    response = @conn.post("L10/create", payload).body
    meeting_id = response["meetingId"]
    meeting_details = {meeting_id: meeting_id, title: title}
    attendees.each do |attendee|
      @conn.post("L10/#{meeting_id}/attendees/#{attendee}")
    end
    meeting_details.merge(attendees: attendees)
  end

  # Deletes a meeting
  #
  # @param meeting_id [Integer] the ID of the meeting to delete
  # @example
  #   client.meeting.delete(1)
  def delete(meeting_id)
    response = @conn.delete("L10/#{meeting_id}")
    response.success?
  end
end
