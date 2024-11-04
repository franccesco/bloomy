# frozen_string_literal: true

require "date"
require_relative "../utils/get_user_id"

# Class to handle all the operations related to todos
class Todo
  include Bloomy::Utilities::UserIdUtility

  # Initializes a new Todo instance
  #
  # @param conn [Object] the connection object to interact with the API
  def initialize(conn)
    @conn = conn
  end

  # Lists all todos for a specific user
  #
  # @param user_id [Integer] the ID of the user (default is the initialized user ID)
  # @return [Array<Hash>] an array of hashes containing todo details
  # @example
  #   client.todo.list
  #   #=> [{ id: 1, title: "Finish report", due_date: "2024-06-10", ... }, ...]
  def list(user_id: self.user_id)
    response = @conn.get("todo/user/#{user_id}").body
    response.map do |todo|
      {
        id: todo["Id"],
        title: todo["Name"],
        due_date: todo["DueDate"],
        created_at: todo["CreateTime"],
        completed_at: todo["CompleteTime"],
        status: todo["Complete"] ? "Complete" : "Incomplete"
      }
    end
  end

  # Creates a new todo
  #
  # @param title [String] the title of the new todo
  # @param meeting_id [Integer] the ID of the meeting associated with the todo
  # @param due_date [String, nil] the due date of the todo (optional)
  # @param user_id [Integer] the ID of the user responsible for the todo (default: initialized user ID)
  # @return [Hash] a hash containing the new todo's details
  # @example
  #   client.todo.create(title: "New Todo", meeting_id: 1, due_date: "2024-06-15")
  #   #=> { id: 1, title: "New Todo", meeting_name: "Team Meeting", ... }
  def create(title:, meeting_id:, due_date: nil, user_id: self.user_id)
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

  # Marks a todo as complete
  #
  # @param todo_id [Integer] the ID of the todo to complete
  # @return [Hash] a hash containing the status of the complete operation
  # @example
  #   todo.complete(1)
  #   #=> { status: 200 }
  def complete(todo_id)
    response = @conn.post("/api/v1/todo/#{todo_id}/complete?status=true")
    {status: response.status}
  end

  # Updates an existing todo
  #
  # @param todo_id [Integer] the ID of the todo to update
  # @param title [String, nil] the new title of the todo (optional)
  # @param due_date [String, nil] the new due date of the todo (optional)
  # @return [Hash] a hash containing the updated todo's details
  # @example
  #   todo.update(1, title: "Updated Todo", due_date: "2024-11-01T01:41:41.528Z")
  #   #=> { id: 1, title: "Updated Todo", due_date: "2024-11-01T01:41:41.528Z", ... }
  def update(todo_id:, title: nil, due_date: nil)
    payload = {}
    payload[:title] = title if title
    payload[:dueDate] = due_date if due_date

    raise ArgumentError, "At least one field must be provided" if payload.empty?

    response = @conn.put("/api/v1/todo/#{todo_id}", payload.to_json)
    raise "Failed to update todo. Status: #{response.status}" unless response.status == 200

    {
      id: todo_id,
      title: title,
      due_date: due_date,
      updated_at: DateTime.now.to_s
    }
  end
end
