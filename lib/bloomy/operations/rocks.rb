# frozen_string_literal: true

# Class to handle all the operations related to rocks
class Rock
  # Initializes a new Rock instance
  #
  # @param conn [Object] the connection object to interact with the API
  # @param user_id [Integer] the ID of the user
  def initialize(conn, user_id)
    @conn = conn
    @user_id = user_id
  end

  # Lists all rocks for a specific user
  #
  # @param user_id [Integer] the ID of the user (default is the initialized user ID)
  # @param archived [Boolean] whether to include archived rocks (default: false)
  # @return [Array<Hash>] an array of hashes containing rock details or a hash with active and archived rocks
  # @example
  #  client.rock.list
  #   #=> [{ id: 1, title: "Complete project", created_at: "2024-06-10", ... }, ...]
  def list(user_id: @user_id, archived: false)
    active_rocks = @conn.get("rocks/user/#{user_id}?include_origin=true").body.map do |rock|
      {
        id: rock["Id"],
        title: rock["Name"],
        created_at: rock["CreateTime"],
        due_date: rock["DueDate"],
        status: rock["Complete"] ? "Completed" : "Incomplete",
        meeting_id: rock["Origins"].empty? ? nil : rock["Origins"][0]["Id"],
        meeting_name: rock["Origins"].empty? ? nil : rock["Origins"][0]["Name"]
      }
    end

    archived ? {active: active_rocks, archived: get_archived_rocks(user_id: @user_id)} : active_rocks
  end

  # Creates a new rock
  #
  # @param title [String] the title of the new rock
  # @param meeting_id [Integer] the ID of the meeting associated with the rock
  # @param user_id [Integer] the ID of the user responsible for the rock (default: initialized user ID)
  # @return [Hash] a hash containing the new rock's details
  # @example
  #   client.rock.create(title: "New Rock", meeting_id: 1)
  #   #=> { rock_id: 1, title: "New Rock", meeting_id: 1, ... }
  def create(title:, meeting_id:, user_id: @user_id)
    payload = {title: title, accountableUserId: user_id}.to_json
    response = @conn.post("/api/v1/L10/#{meeting_id}/rocks", payload).body
    {
      rock_id: response["Id"],
      title: title,
      meeting_id: meeting_id,
      meeting_name: response["Origins"][0]["Name"],
      user_id: user_id,
      user_name: response["Owner"]["Name"],
      created_at: DateTime.parse(response["CreateTime"])
    }
  end

  # Deletes a rock
  #
  # @param rock_id [Integer] the ID of the rock to delete
  # @return [Hash] a hash containing the status of the delete operation
  # @example
  #   client.rock.delete(1)
  #   #=> { status: 200 }
  def delete(rock_id)
    response = @conn.delete("/api/v1/rocks/#{rock_id}")
    {status: response.status}
  end

  # Updates a rock
  #
  # @param rock_id [Integer] the ID of the rock to update
  # @param title [String] the new title of the rock
  # @param accountable_user [Integer] the ID of the user responsible for the rock (default: initialized user ID)
  # @return [Hash] a hash containing the status of the update operation
  # @example
  #   client.rock.update(rock_id: 1, title: "Updated Rock")
  #   #=> { status: 200 }
  def update(rock_id:, title:, accountable_user: @user_id)
    payload = {title: title, accountableUserId: accountable_user}.to_json
    response = @conn.put("/api/v1/rocks/#{rock_id}", payload)
    {status: response.status}
  end

  private

  # Retrieves all archived rocks for a specific user (private method)
  #
  # @param user_id [Integer] the ID of the user (default is the initialized user ID)
  # @return [Array<Hash>] an array of hashes containing archived rock details
  # @example
  #   rock.send(:get_archived_rocks)
  #   #=> [{ id: 1, title: "Archived Rock", created_at: "2024-06-10", ... }, ...]
  def get_archived_rocks(user_id: @user_id)
    response = @conn.get("archivedrocks/user/#{user_id}").body
    response.map do |rock|
      {
        id: rock["Id"],
        title: rock["Name"],
        created_at: rock["CreateTime"],
        due_date: rock["DueDate"],
        status: rock["Complete"] ? "Complete" : "Incomplete"
      }
    end
  end
end
