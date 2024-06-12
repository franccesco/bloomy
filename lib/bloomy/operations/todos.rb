# frozen_string_literal: true

# Class to handle all the operations related to todos
class Todo
  def initialize(conn, user_id)
    @conn = conn
    @user_id = user_id
  end

  def list(user_id: @user_id)
    response = @conn.get("todo/user/#{user_id}").body
    response.map do |todo|
      {
        id: todo["Id"],
        title: todo["Name"],
        due_date: todo["DueDate"],
        created_at: todo["CreateTime"]
      }
    end
  end

  def create(title:, meeting_id:, due_date: nil, user_id: @user_id)
    payload = {title: title, accountableUserId: user_id}
    payload[:dueDate] = due_date if due_date
    response = @conn.post("/api/v1/L10/#{meeting_id}/todos", payload.to_json).body

    {
      id: response["Id"],
      title: response["Name"],
      meeting_name: response["Origin"],
      meeting_id: response["OriginId"],
      due_date: response["DueDate"]
    }
  end
end
