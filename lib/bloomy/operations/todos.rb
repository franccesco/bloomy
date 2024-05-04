# frozen_string_literal: true

module Bloomy
  # The Bloomy module provides operations related to todos.
  module TodoOperations
    include Bloomy::UserOperations
    def get_todos(user_id: get_my_user_id)
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
end
