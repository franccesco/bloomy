# frozen_string_literal: true

require "json"
require "bloomy/utils/get_user_id"

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
  # @return [Hash] a hash containing issue details
  # @example
  #   issue.details(123)
  #   #=> { id: 123, title: "Issue Title", notes_url: "http://details.url", ... }
  def details(issue_id)
    response = @conn.get("issues/#{issue_id}").body
    {
      id: response["Id"],
      title: response["Name"],
      notes_url: response["DetailsUrl"],
      created_at: response["CreateTime"],
      completed_at: response["CloseTime"],
      meeting_details: {
        id: response["OriginId"],
        name: response["Origin"]
      },
      owner_details: {
        id: response["Owner"]["Id"],
        name: response["Owner"]["Name"]
      }
    }
  end

  # Lists issues for a specific user
  #
  # @param user_id [Integer] the ID of the user (default is the initialized user ID)
  # @return [Array<Hash>] an array of hashes containing issues details
  # @example
  #   issue.list
  #   #=> [{ id: 123, title: "Issue Title", notes_url: "http://details.url", ... }, ...]
  def list(user_id = self.user_id)
    response = @conn.get("issues/users/#{user_id}").body
    response.map do |issue|
      {
        id: issue["Id"],
        title: issue["Name"],
        notes_url: issue["DetailsUrl"],
        created_at: issue["CreateTime"],
        meeting_id: issue["OriginId"],
        meeting_name: issue["Origin"]
      }
    end
  end

  # Marks an issue as complete
  #
  # @param issue_id [Integer] the ID of the issue
  # @return [Boolean] true if the operation was successful, false otherwise
  # @example
  #   issue.complete(123)
  #   #=> true
  def complete(issue_id)
    response = @conn.post("issues/#{issue_id}/complete", {complete: true}.to_json).status
    response == 200
  end

  # Creates a new issue
  #
  # @param meeting_id [Integer] the ID of the meeting associated with the issue
  # @param title [String] the title of the new issue
  # @param user_id [Integer] the ID of the user responsible for the issue (default: initialized user ID)
  # @param notes [String, nil] the notes for the issue (optional)
  # @return [Hash] a hash containing the new issue's ID and title
  # @example
  #   issue.create(meeting_id: 123, title: "New Issue")
  #   #=> { id: 789, title: "New Issue" }
  def create(meeting_id:, title:, user_id: self.user_id, notes: nil)
    response = @conn.post("issues/create", {title: title, meetingid: meeting_id, ownerid: user_id, notes: notes}.to_json)
    {
      id: response.body["Id"],
      meeting_id: response.body["OriginId"],
      meeting_title: response.body["Origin"],
      title: response.body["Name"],
      user_id: response.body["Owner"]["Id"],
      notes_url: response.body["DetailsUrl"]
    }
  end
end
