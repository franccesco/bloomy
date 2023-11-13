module Bloomy
  module TodoOperations
    def get_my_todos
      response = @conn.get('todo/users/mine').body
      todos = response.map do |todo|
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
