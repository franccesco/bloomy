# frozen_string_literal: true

require "bloomy/utils/get_user_id"

module Bloomy
  # Class to handle all the operations related to users
  class User
    include Bloomy::Utilities::UserIdUtility
    include Bloomy::Utilities::Transform

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
    # @return [HashWithIndifferentAccess] a hash containing user details
    # @raise [NotFoundError] when user is not found
    # @raise [ApiError] when the API request fails
    def details(user_id = self.user_id, direct_reports: false, positions: false, all: false)
      response = @conn.get("users/#{user_id}")
      data = handle_response(response, context: "get user details")

      user_details = {
        id: data.dig("Id"),
        name: data.dig("Name"),
        image_url: data.dig("ImageUrl")
      }

      user_details[:direct_reports] = direct_reports(user_id) if direct_reports || all
      user_details[:positions] = positions(user_id) if positions || all
      transform_response(user_details)
    end

    # Retrieves direct reports of a specific user
    #
    # @param user_id [Integer] the ID of the user (default: the current user ID)
    # @return [Array<HashWithIndifferentAccess>] an array of hashes containing direct report details
    # @raise [NotFoundError] when user is not found
    # @raise [ApiError] when the API request fails
    def direct_reports(user_id = self.user_id)
      response = @conn.get("users/#{user_id}/directreports")
      data = handle_response(response, context: "get direct reports")

      transform_array(data.map do |report|
        {
          name: report.dig("Name"),
          id: report.dig("Id"),
          image_url: report.dig("ImageUrl")
        }
      end)
    end

    # Retrieves positions of a specific user
    #
    # @param user_id [Integer] the ID of the user (default: the current user ID)
    # @return [Array<HashWithIndifferentAccess>] an array of hashes containing position details
    # @raise [NotFoundError] when user is not found
    # @raise [ApiError] when the API request fails
    def positions(user_id = self.user_id)
      response = @conn.get("users/#{user_id}/seats")
      data = handle_response(response, context: "get user positions")

      transform_array(data.map do |position|
        {
          name: position.dig("Group", "Position", "Name"),
          id: position.dig("Group", "Position", "Id")
        }
      end)
    end

    # Searches for users based on a search term
    #
    # @param term [String] the search term
    # @return [Array<HashWithIndifferentAccess>] an array of hashes containing search results
    # @raise [ApiError] when the API request fails
    def search(term)
      response = @conn.get("search/user", term: term)
      data = handle_response(response, context: "search users")

      transform_array(data.map do |user|
        {
          id: user.dig("Id"),
          name: user.dig("Name"),
          description: user.dig("Description"),
          email: user.dig("Email"),
          organization_id: user.dig("OrganizationId"),
          image_url: user.dig("ImageUrl")
        }
      end)
    end

    # Retrieves all users in the system
    #
    # @param include_placeholders [Boolean] whether to include placeholder users (default: false)
    # @return [Array<HashWithIndifferentAccess>] an array of hashes containing user details
    # @raise [ApiError] when the API request fails
    def all(include_placeholders: false)
      response = @conn.get("search/all", term: "%")
      data = handle_response(response, context: "get all users")

      transform_array(
        data
          .select { |user| user.dig("ResultType") == "User" }
          .select { |user| include_placeholders || user.dig("ImageUrl") != "/i/userplaceholder" }
          .map do |user|
            {
              id: user.dig("Id"),
              name: user.dig("Name"),
              email: user.dig("Email"),
              position: user.dig("Description"),
              image_url: user.dig("ImageUrl")
            }
          end
      )
    end
  end
end
