# frozen_string_literal: true

require "json"
require "bloomy/utils/get_user_id"

module Bloomy
  # Handles CRUD operations for issues in the system.
  # Provides functionality to create, retrieve, list, and solve issues
  # associated with meetings and users.
  class Issue
    include Bloomy::Utilities::UserIdUtility
    include Bloomy::Utilities::Transform
    include Bloomy::Utilities::Validation

    # Initializes a new Issue instance
    #
    # @param conn [Faraday::Connection] Connection object for making API requests
    # @return [Issue] New instance of Issue
    def initialize(conn)
      @conn = conn
    end

    # Retrieves detailed information about a specific issue
    #
    # @param issue_id [Integer] Unique identifier of the issue
    # @return [HashWithIndifferentAccess] Detailed information about the issue
    # @raise [NotFoundError] when issue is not found
    # @raise [ApiError] when the API request fails
    def details(issue_id)
      response = @conn.get("issues/#{issue_id}")
      data = handle_response(response, context: "get issue details")

      transform_response({
        id: data.dig("Id"),
        title: data.dig("Name"),
        notes_url: data.dig("DetailsUrl"),
        created_at: data.dig("CreateTime"),
        completed_at: data.dig("CloseTime"),
        meeting_id: data.dig("OriginId"),
        meeting_title: data.dig("Origin"),
        user_id: data.dig("Owner", "Id"),
        user_name: data.dig("Owner", "Name")
      })
    end

    # Lists issues filtered by user or meeting
    #
    # @param user_id [Integer, nil] Unique identifier of the user (optional)
    # @param meeting_id [Integer, nil] Unique identifier of the meeting (optional)
    # @return [Array<HashWithIndifferentAccess>] List of issues matching the filter criteria
    # @raise [ArgumentError] When both user_id and meeting_id are provided
    # @raise [NotFoundError] when user or meeting is not found
    # @raise [ApiError] when the API request fails
    def list(user_id: nil, meeting_id: nil)
      if user_id && meeting_id
        raise ArgumentError, "Please provide either `user_id` or `meeting_id`, not both."
      end

      if meeting_id
        response = @conn.get("l10/#{meeting_id}/issues")
        data = handle_response(response, context: "list meeting issues")
      else
        response = @conn.get("issues/users/#{user_id || self.user_id}")
        data = handle_response(response, context: "list user issues")
      end

      transform_array(data.map do |issue|
        {
          id: issue.dig("Id"),
          title: issue.dig("Name"),
          notes_url: issue.dig("DetailsUrl"),
          created_at: issue.dig("CreateTime"),
          meeting_id: issue.dig("OriginId"),
          meeting_title: issue.dig("Origin")
        }
      end)
    end

    # Marks an issue as completed/solved
    #
    # @param issue_id [Integer] Unique identifier of the issue to be solved
    # @return [Boolean] true if issue was successfully solved
    # @raise [NotFoundError] when issue is not found
    # @raise [ApiError] when the API request fails
    def solve(issue_id)
      response = @conn.post("issues/#{issue_id}/complete", {complete: true}.to_json)
      handle_response!(response, context: "solve issue")
    end

    # Creates a new issue in the system
    #
    # @param meeting_id [Integer] Unique identifier of the associated meeting
    # @param title [String] Title/name of the issue
    # @param user_id [Integer] Unique identifier of the issue owner (defaults to current user)
    # @param notes [String, nil] Additional notes or description for the issue (optional)
    # @return [HashWithIndifferentAccess] Newly created issue details
    # @raise [ArgumentError] if title is empty or meeting_id is invalid
    # @raise [NotFoundError] when meeting is not found
    # @raise [ApiError] when the API request fails
    def create(meeting_id:, title:, user_id: self.user_id, notes: nil)
      validate_title!(title)
      validate_id!(meeting_id, context: "meeting_id")

      response = @conn.post("issues/create", {title: title, meetingid: meeting_id, ownerid: user_id, notes: notes}.to_json)
      data = handle_response(response, context: "create issue")

      transform_response({
        id: data.dig("Id"),
        meeting_id: data.dig("OriginId"),
        meeting_title: data.dig("Origin"),
        title: data.dig("Name"),
        user_id: data.dig("Owner", "Id"),
        notes_url: data.dig("DetailsUrl")
      })
    end

    # Updates an existing issue's title or notes
    #
    # @param issue_id [Integer] Unique identifier of the issue to update
    # @param title [String, nil] New title for the issue (optional)
    # @param notes [String, nil] New notes for the issue (optional)
    # @return [HashWithIndifferentAccess] Updated issue details
    # @raise [ArgumentError] When neither title nor notes is provided
    # @raise [NotFoundError] when issue is not found
    # @raise [ApiError] when the API request fails
    def update(issue_id:, title: nil, notes: nil)
      raise ArgumentError, "Provide at least one field to update" if title.nil? && notes.nil?

      payload = {}
      payload[:title] = title if title
      payload[:notes] = notes if notes
      response = @conn.put("issues/#{issue_id}", payload.to_json)
      handle_response!(response, context: "update issue")

      details(issue_id)
    end

    # Deletes an issue from a meeting
    #
    # @param issue_id [Integer] Unique identifier of the issue to delete
    # @param meeting_id [Integer] Unique identifier of the meeting containing the issue
    # @return [Boolean] true if issue was successfully deleted
    # @raise [ArgumentError] if issue_id or meeting_id is invalid
    # @raise [NotFoundError] when issue or meeting is not found
    # @raise [ApiError] when the API request fails
    # @example
    #   client.issue.delete(123, meeting_id: 456)
    #   #=> true
    def delete(issue_id, meeting_id:)
      validate_id!(issue_id, context: "issue_id")
      validate_id!(meeting_id, context: "meeting_id")

      response = @conn.delete("L10/#{meeting_id}/issues/#{issue_id}")
      handle_response!(response, context: "delete issue")
    end
  end
end
