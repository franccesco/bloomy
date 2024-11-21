# frozen_string_literal: true

require "bloomy/utils/get_user_id"
require "bloomy/types/items"

# Class to handle all the operations related to users
class User
  include Bloomy::Utilities::UserIdUtility

  # Initializes a new User instance
  #
  # @param conn [Object] the connection object to interact with the API
  def initialize(conn)
    @conn = conn
  end

  # Retrieves details of a specific user
  #
  # @param user_id [Integer] the ID of the user (default: the current user ID)
  # @param direct_reports [Boolean] whether to include direct reports (default: false)
  # @param positions [Boolean] whether to include positions (default: false)
  # @param all [Boolean] whether to include both direct reports and positions (default: false)
  # @return [Hash] a hash containing user details
  # @example
  #   client.user.details
  #   #=> {name: "John Doe", id: 1, image_url: "http://example.com/image.jpg", ...}
  def details(user_id = self.user_id, direct_reports: false, positions: false, all: false)
    response = @conn.get("users/#{user_id}").body
    user_details = UserItem.new(
      id: response["Id"],
      name: response["Name"],
      image_url: response["ImageUrl"]
    )

    user_details.direct_reports = direct_reports(user_id) if direct_reports || all
    user_details.positions = positions(user_id) if positions || all
    user_details
  end

  # Retrieves direct reports of a specific user
  #
  # @param user_id [Integer] the ID of the user (default: the current user ID)
  # @return [Array<Hash>] an array of hashes containing direct report details
  # @example
  #   client.user.direct_reports
  #   #=> [{name: "Jane Smith", id: 2, image_url: "http://example.com/image.jpg"}, ...]
  def direct_reports(user_id = self.user_id)
    direct_reports_response = @conn.get("users/#{user_id}/directreports").body
    direct_reports_response.map do |report|
      UserItem.new(
        name: report["Name"],
        id: report["Id"],
        image_url: report["ImageUrl"]
      )
    end
  end

  # Retrieves positions of a specific user
  #
  # @param user_id [Integer] the ID of the user (default: the current user ID)
  # @return [Array<Hash>] an array of hashes containing position details
  # @example
  #   user.positions
  #   #=> [{name: "Manager", id: 3}, ...]
  def positions(user_id = self.user_id)
    position_response = @conn.get("users/#{user_id}/seats").body
    position_response.map do |position|
      UserItem.new(
        name: position["Group"]["Position"]["Name"],
        id: position["Group"]["Position"]["Id"]
      )
    end
  end

  # Searches for users based on a search term
  #
  # @param term [String] the search term
  # @return [Array<Hash>] an array of hashes containing search results
  # @example
  #   user.search("John")
  #   #=> [{id: 1, name: "John Doe", description: "Developer", ...}, ...]
  def search(term)
    response = @conn.get("search/user", term: term).body
    response.map do |user|
      UserItem.new(
        id: user["Id"],
        name: user["Name"],
        description: user["Description"],
        email: user["Email"],
        organization_id: user["OrganizationId"],
        image_url: user["ImageUrl"]
      )
    end
  end

  # Retrieves all users in the system
  #
  # @param include_placeholders [Boolean] whether to include users
  # @return [Array<Hash>] an array of hashes containing user details
  # @example
  #   user.all
  #   #=> [{id: 1, name: "John Doe", email: "john@example.com", ...}, ...]
  def all(include_placeholders: false)
    users = @conn.get("search/all", term: "%").body
    users
      .select { |user| user["ResultType"] == "User" }
      .reject { |user| !include_placeholders && user["ImageUrl"] == "/i/userplaceholder" }
      .map do |user|
        UserItem.new(
          id: user["Id"],
          name: user["Name"],
          email: user["Email"],
          position: user["Description"],
          image_url: user["ImageUrl"]
        )
      end
  end
end
