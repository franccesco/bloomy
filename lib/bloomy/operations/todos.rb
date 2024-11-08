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

  # Lists all todos for a specific user or meeting
  #
  # @param user_id [Integer, nil] the ID of the user (default is the initialized user ID)
  # @param meeting_id [Integer, nil] the ID of the meeting
  # @return [Array<Hash>] an array of hashes containing todo details
  # @raise [ArgumentError] if both `user_id` and `meeting_id` are provided
  # @example
  #   # Fetch todos for the current user
  #   client.todo.list
  #   #=> [{ id: 1, title: "New Todo", due_date: "2024-06-15", ... }]
  #
  #   # Fetch todos for a specific user
  #   client.todo.list(user_id: 42)
  #   # => [{ id: 1, title: "New Todo", due_date: "2024-06-15", ... }]
  #
  #   # Fetch todos for a specific meeting
  #   client.todo.list(meeting_id: 99)
  #   # => [{ id: 1, title: "New Todo", due_date: "2024-06-15", ... }]
  def list(user_id: nil, meeting_id: nil)
    raise ArgumentError, "Please provide either `user_id` or `meeting_id`, not both." if user_id && meeting_id

    if meeting_id
      response = @conn.get("l10/#{meeting_id}/todos").body
    else
      user_id ||= self.user_id
      response = @conn.get("todo/user/#{user_id}").body
    end

    response.map do |todo|
      {
        id: todo["Id"],
        title: todo["Name"],
        notes_url: todo["DetailsUrl"],
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
  # @param notes [String, nil] additional notes for the todo (optional)
  # @return [Hash] a hash containing the new todo's details
  # @example
  #   client.todo.create(title: "New Todo", meeting_id: 1, due_date: "2024-06-15")
  #   #=> { id: 1, title: "New Todo", meeting_name: "Team Meeting", ... }
  def create(title:, meeting_id:, due_date: nil, user_id: self.user_id, notes: nil)
    payload = {title: title, accountableUserId: user_id, notes: notes}
    payload[:dueDate] = due_date if due_date
    response = @conn.post("/api/v1/L10/#{meeting_id}/todos", payload.to_json).body

    {
      id: response["Id"],
      title: response["Name"],
      meeting_title: response["Origin"],
      meeting_id: response["OriginId"],
      due_date: response["DueDate"],
      notes_url: response["DetailsUrl"]
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
    response.success?
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

  # Retrieves the details of a specific todo item by its ID.
  #
  # @param todo_id [String] The ID of the todo item to retrieve.
  # @return [Hash] A hash containing the details of the todo item.
  # @raise [RuntimeError] If the request to retrieve the todo details fails.
  # @example
  #  client.todo.details(1)
  #  #=> { id: 1, title: "Updated Todo", due_date: "2024-11-01T01:41:41.528Z", ... }
  def details(todo_id)
    response = @conn.get("/api/v1/todo/#{todo_id}")
    raise "Failed to get todo details. Status: #{response.status}" unless response.success?

    todo = response.body
    {
      id: todo["Id"],
      meeting_id: todo["OriginId"],
      meeting_title: todo["Origin"],
      title: todo["Name"],
      notes_url: todo["DetailsUrl"],
      due_date: todo["DueDate"],
      created_at: todo["CreateTime"],
      completed_at: todo["CompleteTime"],
      status: todo["Complete"] ? "Complete" : "Incomplete"
    }
  end
end
