# frozen_string_literal: true

require "bloomy/utils/get_user_id"

module Bloomy
  class Headline
    include Bloomy::Utilities::UserIdUtility
    include Bloomy::Utilities::Transform
    include Bloomy::Utilities::Validation

    # Initializes a new headline instance
    #
    # @param conn [Object] the connection object to interact with the API
    def initialize(conn)
      @conn = conn
    end

    # Creates a new headline
    #
    # @param meeting_id [Integer] the ID of the meeting
    # @param title [String] the title of the headline
    # @param owner_id [Integer] the ID of the headline owner
    # @param notes [String] additional notes for the headline
    # @return [HashWithIndifferentAccess] containing id, title, owner_details, and notes_url
    # @raise [ArgumentError] if title is empty or meeting_id is invalid
    # @raise [NotFoundError] when meeting is not found
    # @raise [ApiError] when the API request fails
    def create(meeting_id:, title:, owner_id: user_id, notes: nil)
      validate_title!(title)
      validate_id!(meeting_id, context: "meeting_id")

      response = @conn.post("L10/#{meeting_id}/headlines",
        {title: title, ownerId: owner_id, notes: notes}.to_json)
      data = handle_response(response, context: "create headline")

      transform_response({
        id: data.dig("Id"),
        title: data.dig("Name"),
        owner_details: {id: data.dig("OwnerId")},
        notes_url: data.dig("DetailsUrl")
      })
    end

    # Updates a headline
    #
    # @param headline_id [Integer] the ID of the headline to update
    # @param title [String] the new title of the headline
    # @return [HashWithIndifferentAccess] the updated headline details
    # @raise [NotFoundError] when headline is not found
    # @raise [ApiError] when the API request fails
    def update(headline_id:, title:)
      response = @conn.put("headline/#{headline_id}", {title: title}.to_json)
      handle_response!(response, context: "update headline")

      details(headline_id)
    end

    # Get headline details
    #
    # @param headline_id [Integer] the ID of the headline
    # @return [HashWithIndifferentAccess] containing id, title, notes_url, meeting_details,
    #                owner_details, archived, created_at, and closed_at
    # @raise [NotFoundError] when headline is not found
    # @raise [ApiError] when the API request fails
    def details(headline_id)
      response = @conn.get("headline/#{headline_id}?Include_Origin=true")
      data = handle_response(response, context: "get headline details")

      transform_response({
        id: data.dig("Id"),
        title: data.dig("Name"),
        notes_url: data.dig("DetailsUrl"),
        meeting_details: {
          id: data.dig("OriginId"),
          title: data.dig("Origin")
        },
        owner_details: {
          id: data.dig("Owner", "Id"),
          name: data.dig("Owner", "Name")
        },
        archived: data.dig("Archived"),
        created_at: data.dig("CreateTime"),
        closed_at: data.dig("CloseTime")
      })
    end

    # Get headlines for a user or a meeting.
    #
    # @param user_id [Integer, nil] the ID of the user (defaults to initialized user_id)
    # @param meeting_id [Integer, nil] the ID of the meeting
    # @raise [ArgumentError] if both `user_id` and `meeting_id` are provided
    # @raise [NotFoundError] when user or meeting is not found
    # @raise [ApiError] when the API request fails
    # @return [Array<HashWithIndifferentAccess>] a list of headlines containing:
    #   - id
    #   - title
    #   - meeting_details
    #   - owner_details
    #   - archived
    #   - created_at
    #   - closed_at
    # @example
    #   client.headline.list
    #   #=> [
    #     {
    #       id: 1,
    #       title: "Headline Title",
    #       meeting_details: { id: 1, title: "Team Meeting" },
    #       owner_details: { id: 1, name: "John Doe" },
    #       archived: false,
    #       created_at: "2023-01-01",
    #       closed_at: nil
    #     }
    #   ]
    def list(user_id: nil, meeting_id: nil)
      raise ArgumentError, "Please provide either `user_id` or `meeting_id`, not both." if user_id && meeting_id

      if meeting_id
        response = @conn.get("l10/#{meeting_id}/headlines")
        data = handle_response(response, context: "list meeting headlines")
      else
        user_id ||= self.user_id
        response = @conn.get("headline/users/#{user_id}")
        data = handle_response(response, context: "list user headlines")
      end

      transform_array(data.map do |headline|
        {
          id: headline.dig("Id"),
          title: headline.dig("Name"),
          meeting_details: {
            id: headline.dig("OriginId"),
            title: headline.dig("Origin")
          },
          owner_details: {
            id: headline.dig("Owner", "Id"),
            name: headline.dig("Owner", "Name")
          },
          archived: headline.dig("Archived"),
          created_at: headline.dig("CreateTime"),
          closed_at: headline.dig("CloseTime")
        }
      end)
    end

    # Deletes a headline
    #
    # @param headline_id [Integer] the ID of the headline to delete
    # @return [Boolean] true if the deletion was successful
    # @raise [NotFoundError] when headline is not found
    # @raise [ApiError] when the API request fails
    def delete(headline_id)
      response = @conn.delete("headline/#{headline_id}")
      handle_response!(response, context: "delete headline")
    end
  end
end
