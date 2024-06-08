# frozen_string_literal: true

# Class to handle all the operations related to rocks
class Rock
  def initialize(conn, user_id)
    @conn = conn
    @user_id = user_id
  end

  def list(user_id: @user_id, archived: false)
    active_rocks = @conn.get("rocks/user/#{user_id}").body.map do |rock|
      {
        id: rock["Id"],
        title: rock["Name"],
        created_at: rock["CreateTime"],
        due_date: rock["DueDate"],
        status: rock["Complete"] ? "Completed" : "Incomplete"
      }
    end

    archived ? {active: active_rocks, archived: get_archived_rocks(user_id: @user_id)} : active_rocks
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
