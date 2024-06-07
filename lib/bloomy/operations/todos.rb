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
        id: todo['Id'],
        title: todo['Name'],
        due_date: todo['DueDate'],
        created_at: todo['CreateTime']
      }
    end
  end
end
