# frozen_string_literal: true

require "bloomy/utils/get_user_id"

module Bloomy
  # Class to handle all the operations related to meeting
  # @note
  #   This class is already initialized via the client and usable as `client.meeting.method`
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
    # @raise [NotFoundError] when user is not found
    # @raise [ApiError] when the API request fails
    # @example
    #   client.meeting.list
    #   #=> [{ id: 123, name: "Team Meeting" }, ...]
    def list(user_id = self.user_id)
      response = @conn.get("L10/#{user_id}/list")
      data = handle_response(response, context: "list meetings")

      data.map { |meeting| {id: meeting.dig("Id"), title: meeting.dig("Name")} }
    end

    # Lists all attendees for a specific meeting
    #
    # @param meeting_id [Integer] the ID of the meeting
    # @return [Array<Hash>] an array of hashes containing attendee details
    # @raise [NotFoundError] when meeting is not found
    # @raise [ApiError] when the API request fails
    # @example
    #   client.meeting.attendees(1)
    #   #=> [{ name: "John Doe", id: 1 }, ...]
    def attendees(meeting_id)
      response = @conn.get("L10/#{meeting_id}/attendees")
      data = handle_response(response, context: "get meeting attendees")

      data.map { |attendee| {id: attendee.dig("Id"), name: attendee.dig("Name")} }
    end

    # Lists all issues for a specific meeting
    #
    # @param meeting_id [Integer] the ID of the meeting
    # @param include_closed [Boolean] whether to include closed issues (default: false)
    # @return [Array<Hash>] an array of hashes containing issue details
    # @raise [NotFoundError] when meeting is not found
    # @raise [ApiError] when the API request fails
    # @example
    #   client.meeting.issues(1)
    #   #=> [{ id: 1, title: "Issue Title", created_at: "2024-06-10", ... }, ...]
    def issues(meeting_id, include_closed: false)
      response = @conn.get("L10/#{meeting_id}/issues?include_resolved=#{include_closed}")
      data = handle_response(response, context: "get meeting issues")

      data.map do |issue|
        {
          id: issue.dig("Id"),
          title: issue.dig("Name"),
          notes_url: issue.dig("DetailsUrl"),
          created_at: issue.dig("CreateTime"),
          completed_at: issue.dig("CloseTime"),
          user_id: issue.dig("Owner", "Id"),
          user_name: issue.dig("Owner", "Name"),
          meeting_id: meeting_id,
          meeting_title: issue.dig("Origin")
        }
      end
    end

    # Lists all todos for a specific meeting
    #
    # @param meeting_id [Integer] the ID of the meeting
    # @param include_closed [Boolean] whether to include closed todos (default: false)
    # @return [Array<Hash>] an array of hashes containing todo details
    # @raise [NotFoundError] when meeting is not found
    # @raise [ApiError] when the API request fails
    # @example
    #   client.meeting.todos(1)
    #   #=> [{ id: 1, title: "Todo Title", due_date: "2024-06-12", ... }, ...]
    def todos(meeting_id, include_closed: false)
      response = @conn.get("L10/#{meeting_id}/todos?INCLUDE_CLOSED=#{include_closed}")
      data = handle_response(response, context: "get meeting todos")

      data.map do |todo|
        {
          id: todo.dig("Id"),
          title: todo.dig("Name"),
          due_date: todo.dig("DueDate"),
          notes_url: todo.dig("DetailsUrl"),
          status: todo.dig("Complete") ? "Complete" : "Incomplete",
          created_at: todo.dig("CreateTime"),
          completed_at: todo.dig("CompleteTime"),
          user_id: todo.dig("Owner", "Id"),
          user_name: todo.dig("Owner", "Name")
        }
      end
    end

    # Lists all metrics for a specific meeting
    #
    # @param meeting_id [Integer] the ID of the meeting
    # @return [Array<Hash>] an array of hashes containing metric details
    # @raise [NotFoundError] when meeting is not found
    # @raise [ApiError] when the API request fails
    # @example
    #   client.meeting.metrics(1)
    #   #=> [{ id: 1, name: "Sales", target: 100, operator: ">", format: "currency", ... }, ...]
    def metrics(meeting_id)
      response = @conn.get("L10/#{meeting_id}/measurables")
      data = handle_response(response, context: "get meeting metrics")

      return [] if data.nil? || !data.is_a?(Array)

      data.filter_map do |measurable|
        next unless measurable.dig("Id") && measurable.dig("Name")

        {
          id: measurable.dig("Id"),
          title: measurable.dig("Name").to_s.strip,
          target: measurable.dig("Target").to_f,
          operator: measurable.dig("Direction").to_s,
          format: measurable.dig("Modifiers").to_s,
          user_id: measurable.dig("Owner", "Id"),
          user_name: measurable.dig("Owner", "Name"),
          admin_id: measurable.dig("Admin", "Id"),
          admin_name: measurable.dig("Admin", "Name")
        }
      end
    end

    # Retrieves details of a specific meeting
    #
    # @param meeting_id [Integer] the ID of the meeting
    # @param include_closed [Boolean] whether to include closed issues and todos (default: false)
    # @return [Hash] a hash containing detailed information about the meeting
    # @raise [NotFoundError] when meeting is not found
    # @raise [ApiError] when the API request fails
    # @example
    #   client.meeting.details(1)
    #   #=> { id: 1, name: "Team Meeting", attendees: [...], issues: [...], todos: [...], metrics: [...] }
    def details(meeting_id, include_closed: false)
      meeting = list.find { |m| m[:id] == meeting_id }
      {
        id: meeting&.dig(:id),
        title: meeting&.dig(:title),
        attendees: attendees(meeting_id),
        issues: issues(meeting_id, include_closed: include_closed),
        todos: todos(meeting_id, include_closed: include_closed),
        metrics: metrics(meeting_id)
      }
    end

    # Creates a new meeting
    #
    # @param title [String] the title of the new meeting
    # @param add_self [Boolean] whether to add the current user as an attendee (default: true)
    # @param attendees [Array<Integer>] a list of user IDs to add as attendees
    # @return [Hash] a hash containing meeting_id, title and attendees array
    # @raise [ApiError] when the API request fails
    # @example
    #   client.meeting.create("New Meeting", attendees: [2, 3])
    #   #=> { meeting_id: 1, title: "New Meeting", attendees: [2, 3] }
    def create(title, add_self: true, attendees: [])
      payload = {title: title, addSelf: add_self}.to_json
      response = @conn.post("L10/create", payload)
      data = handle_response(response, context: "create meeting")

      meeting_id = data.dig("meetingId")
      meeting_details = {meeting_id: meeting_id, title: title}
      attendees.each do |attendee|
        @conn.post("L10/#{meeting_id}/attendees/#{attendee}")
      end
      meeting_details.merge(attendees: attendees)
    end

    # Deletes a meeting
    #
    # @param meeting_id [Integer] the ID of the meeting to delete
    # @return [Boolean] true if deletion was successful
    # @raise [NotFoundError] when meeting is not found
    # @raise [ApiError] when the API request fails
    # @example
    #   client.meeting.delete(1)
    #   #=> true
    def delete(meeting_id)
      response = @conn.delete("L10/#{meeting_id}")
      handle_response!(response, context: "delete meeting")
    end
  end
end
