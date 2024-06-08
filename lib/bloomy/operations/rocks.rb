# frozen_string_literal: true

# Class to handle all the operations related to rocks
class Rock
  def initialize(conn, user_id)
    @conn = conn
    @user_id = user_id
  end

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

  def delete(rock_id)
    response = @conn.delete("/api/v1/rocks/#{rock_id}")
    {status: response.status}
  end

  def update(rock_id:, title:, accountable_user: @user_id)
    payload = {title: title, accountableUserId: accountable_user}.to_json
    response = @conn.put("/api/v1/rocks/#{rock_id}", payload)
    {status: response.status}
  end

  private

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
