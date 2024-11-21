# frozen_string_literal: true

require "json"
require "bloomy/utils/get_user_id"
require "bloomy/types/items"

# Class to handle all the operations related to issues
class Issue
  include Bloomy::Utilities::UserIdUtility
  # Initializes a new Issue instance
  #
  # @param conn [Object] the connection object to interact with the API
  def initialize(conn)
    @conn = conn
  end

  # Retrieves details of a specific issue
  #
  # @param issue_id [Integer] the ID of the issue
  # @return [IssueDetails] an IssueDetails struct containing issue details
  # @example
  #   issue.details(123)
  #   #=> #<IssueDetails id=123 title="Issue Title" notes_url="http://details.url" ...>
  def details(issue_id)
    response = @conn.get("issues/#{issue_id}").body
    IssueDetails.new(
      id: response["Id"],
      title: response["Name"],
      notes_url: response["DetailsUrl"],
      created_at: response["CreateTime"],
      completed_at: response["CloseTime"],
      meeting_details: MeetingItem.new(
        id: response["OriginId"],
        title: response["Origin"]
      ),
      owner_details: UserItem.new(
        id: response["Owner"]["Id"],
        name: response["Owner"]["Name"]
      )
    )
  end

  # Lists issues for a specific user or meeting
  #
  # @param user_id [Integer, nil] the ID of the user (defaults to initialized user_id)
  # @param meeting_id [Integer, nil] the ID of the meeting
  # @raise [ArgumentError] if both `user_id` and `meeting_id` are provided
  # @return [Array<IssueItem>] an array of IssueItem structs containing issues details
  # @example
  #   # Fetch issues for the current user
  #   issue.list
  #
  #   # Fetch issues for a specific user
  #   issue.list(user_id: 42)
  #
  #   # Fetch issues for a specific meeting
  #   issue.list(meeting_id: 99)
  def list(user_id: nil, meeting_id: nil)
    if user_id && meeting_id
      raise ArgumentError, "Please provide either `user_id` or `meeting_id`, not both."
    end

    response = meeting_id ? @conn.get("l10/#{meeting_id}/issues").body : @conn.get("issues/users/#{user_id || self.user_id}").body

    response.map do |issue|
      IssueItem.new(
        id: issue["Id"],
        title: issue["Name"],
        notes_url: issue["DetailsUrl"],
        created_at: issue["CreateTime"],
        meeting_id: issue["OriginId"],
        meeting_title: issue["Origin"]
      )
    end
  end

  # Marks an issue as solved
  #
  # @param issue_id [Integer] the ID of the issue
  # @return [Boolean] true if the operation was successful, false otherwise
  # @example
  #   issue.solve(123)
  #   #=> true
  def solve(issue_id)
    response = @conn.post("issues/#{issue_id}/complete", {complete: true}.to_json)
    response.success?
  end

  # Creates a new issue
  #
  # @param meeting_id [Integer] the ID of the meeting associated with the issue
  # @param title [String] the title of the new issue
  # @param user_id [Integer] the ID of the user responsible for the issue (default: initialized user ID)
  # @param notes [String, nil] the notes for the issue (optional)
  # @return [IssueItem] an IssueItem struct containing the new issue's ID and title
  # @example
  #   issue.create(meeting_id: 123, title: "New Issue")
  #   #=> #<IssueItem id=789 title="New Issue" ...>
  def create(meeting_id:, title:, user_id: self.user_id, notes: nil)
    response = @conn.post("issues/create", {title: title, meetingid: meeting_id, ownerid: user_id, notes: notes}.to_json)
    IssueItem.new(
      id: response.body["Id"],
      meeting_id: response.body["OriginId"],
      meeting_title: response.body["Origin"],
      title: response.body["Name"],
      user_id: response.body["Owner"]["Id"],
      notes_url: response.body["DetailsUrl"]
    )
  end
end
