# frozen_string_literal: true

require "bloomy/utils/get_user_id"

module Bloomy
  # Class to handle all the operations related to goals (also known as "rocks")
  # @note This class is already initialized via the client and usable as `client.goal.method`
  class Goal
    include Bloomy::Utilities::UserIdUtility
    include Bloomy::Utilities::Transform
    include Bloomy::Utilities::Validation

    # @return [Hash] Maps status symbols to API completion values
    COMPLETION_VALUES = {complete: 2, on: 1, off: 0}.freeze

    # @return [Hash] Maps status symbols to API status strings
    STATUS_MAPPINGS = {on: "OnTrack", off: "AtRisk", complete: "Complete"}.freeze

    # Initializes a new Goal instance
    #
    # @param conn [Object] the connection object to interact with the API
    def initialize(conn)
      @conn = conn
    end

    # Lists all goals for a specific user
    #
    # @param user_id [Integer, nil] the ID of the user (default: current user)
    # @param archived [Boolean] whether to include archived goals (default: false)
    # @return [Array<HashWithIndifferentAccess>, HashWithIndifferentAccess] Returns either:
    #   - An array of goal hashes if archived is false
    #   - A hash with :active and :archived arrays of goal hashes if archived is true
    # @raise [NotFoundError] when user is not found
    # @raise [ApiError] when the API request fails
    # @example List active goals
    #   client.goal.list
    #   #=> [{ id: 1, title: "Complete project", ... }]
    #
    # @example List both active and archived goals
    #   client.goal.list(archived: true)
    #   #=> {
    #     active: [{ id: 1, ... }],
    #     archived: [{ id: 2, ... }]
    #   }
    #
    # @example List goals for specific user
    #   client.goal.list(user_id: 42)
    def list(user_id: nil, archived: false)
      user_id ||= self.user_id
      response = @conn.get("rocks/user/#{user_id}?include_origin=true")
      data = handle_response(response, context: "list goals")

      active_goals = transform_array(data.map do |goal|
        origins = goal.dig("Origins") || []
        {
          id: goal.dig("Id"),
          user_id: goal.dig("Owner", "Id"),
          user_name: goal.dig("Owner", "Name"),
          title: goal.dig("Name"),
          created_at: goal.dig("CreateTime"),
          due_date: goal.dig("DueDate"),
          status: goal.dig("Complete") ? "Completed" : "Incomplete",
          meeting_id: origins.empty? ? nil : origins.dig(0, "Id"),
          meeting_title: origins.empty? ? nil : origins.dig(0, "Name")
        }
      end)

      archived ? transform_response({active: active_goals, archived: get_archived_goals(user_id)}) : active_goals
    end

    # Creates a new goal
    #
    # @param title [String] the title of the new goal
    # @param meeting_id [Integer] the ID of the meeting associated with the goal
    # @param user_id [Integer] the ID of the user responsible for the goal (default: initialized user ID)
    # @return [HashWithIndifferentAccess] the newly created goal
    # @raise [ArgumentError] if title is empty or meeting_id is invalid
    # @raise [NotFoundError] when meeting is not found
    # @raise [ApiError] when the API request fails
    # @example
    #   client.goal.create(title: "New Goal", meeting_id: 1)
    #   #=> { id: 1, title: "New Goal", meeting_id: 1, ... }
    def create(title:, meeting_id:, user_id: self.user_id)
      validate_title!(title)
      validate_id!(meeting_id, context: "meeting_id")

      payload = {title: title, accountableUserId: user_id}.to_json
      response = @conn.post("L10/#{meeting_id}/rocks", payload)
      data = handle_response(response, context: "create goal")

      origins = data.dig("Origins") || []
      transform_response({
        id: data.dig("Id"),
        user_id: user_id,
        user_name: data.dig("Owner", "Name"),
        title: title,
        meeting_id: meeting_id,
        meeting_title: origins.dig(0, "Name"),
        status: COMPLETION_VALUES.key(data.dig("Completion")).to_s,
        created_at: data.dig("CreateTime")
      })
    end

    # Deletes a goal
    #
    # @param goal_id [Integer] the ID of the goal to delete
    # @return [Boolean] true if deletion was successful
    # @raise [NotFoundError] when goal is not found
    # @raise [ApiError] when the API request fails
    # @example
    #   client.goal.delete(1)
    #   #=> true
    def delete(goal_id)
      response = @conn.delete("rocks/#{goal_id}")
      handle_response!(response, context: "delete goal")
    end

    # Updates a goal
    #
    # @param goal_id [Integer] the ID of the goal to update
    # @param title [String] the new title of the goal
    # @param accountable_user [Integer] the ID of the user responsible for the goal (default: initialized user ID)
    # @param status [String, nil] the status value ('on', 'off', or 'complete')
    # @return [HashWithIndifferentAccess] the updated goal
    # @raise [ArgumentError] if an invalid status value is provided
    # @raise [NotFoundError] when goal is not found
    # @raise [ApiError] when the API request fails
    # @example
    #   client.goal.update(goal_id: 1, title: "Updated Goal", status: 'on')
    #   #=> { id: 1, title: "Updated Goal", status: "OnTrack", ... }
    def update(goal_id:, title: nil, accountable_user: user_id, status: nil)
      if status
        status_key = status.downcase.to_sym
        unless STATUS_MAPPINGS.key?(status_key)
          raise ArgumentError, "Invalid status value. Must be 'on', 'off', or 'complete'."
        end
        status = STATUS_MAPPINGS[status_key]
      end
      payload = {title: title, accountableUserId: accountable_user, completion: status}.to_json
      response = @conn.put("rocks/#{goal_id}", payload)
      handle_response!(response, context: "update goal")

      transform_response({
        id: goal_id,
        title: title,
        user_id: accountable_user,
        status: status
      })
    end

    # Archives a rock with the specified goal ID.
    #
    # @param goal_id [Integer] The ID of the goal/rock to archive
    # @return [Boolean] Returns true if the archival was successful
    # @raise [NotFoundError] when goal is not found
    # @raise [ApiError] when the API request fails
    # @example
    #  goals.archive(123) #=> true
    def archive(goal_id)
      response = @conn.put("rocks/#{goal_id}/archive")
      handle_response!(response, context: "archive goal")
    end

    # Restores a previously archived goal identified by the provided goal ID.
    #
    # @param [String, Integer] goal_id The unique identifier of the goal to restore
    # @return [Boolean] true if the restore operation was successful
    # @raise [NotFoundError] when goal is not found
    # @raise [ApiError] when the API request fails
    # @example Restoring a goal
    #   goals.restore("123") #=> true
    def restore(goal_id)
      response = @conn.put("rocks/#{goal_id}/restore")
      handle_response!(response, context: "restore goal")
    end

    private

    # Retrieves all archived goals for a specific user (private method)
    #
    # @param user_id [Integer] the ID of the user (default is the initialized user ID)
    # @return [Array<HashWithIndifferentAccess>] an array of hashes containing archived goal details
    # @raise [NotFoundError] when user is not found
    # @raise [ApiError] when the API request fails
    # @example
    #   goal.send(:get_archived_goals)
    #   #=> [{ id: 1, title: "Archived Goal", created_at: "2024-06-10", ... }, ...]
    def get_archived_goals(user_id = self.user_id)
      response = @conn.get("archivedrocks/user/#{user_id}")
      data = handle_response(response, context: "get archived goals")

      transform_array(data.map do |goal|
        {
          id: goal.dig("Id"),
          title: goal.dig("Name"),
          created_at: goal.dig("CreateTime"),
          due_date: goal.dig("DueDate"),
          status: goal.dig("Complete") ? "Complete" : "Incomplete"
        }
      end)
    end
  end
end
