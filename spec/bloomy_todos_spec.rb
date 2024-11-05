# frozen_string_literal: true

require "date"

RSpec.describe "Todo Operations" do
  before(:all) do
    @client = Bloomy::Client.new
    @meeting_id = @client.meeting.create(title: "Test Meeting")[:meeting_id]
    @due_date_7days = (Date.today + 7).to_s
    @todo = @client.todo.create(title: "New Todo", meeting_id: @meeting_id, notes: "Note!")
  end

  after(:all) do
    @client.meeting.delete(@meeting_id)
  end

  context "when interacting with todos API" do
    it "creates a todo" do
      expect(@todo).to include(
        {
          id: a_kind_of(Integer),
          title: a_kind_of(String),
          meeting_id: eq(@meeting_id),
          meeting_name: a_kind_of(String),
          due_date: a_kind_of(String),
          notes_url: a_kind_of(String)
        }
      )
    end

    it "updates a todo" do
      updated_todo = @client.todo.update(todo_id: @todo[:id], title: "Updated Todo")
      expect(updated_todo).to include(
        id: eq(@todo[:id]),
        title: eq("Updated Todo"),
        updated_at: a_kind_of(String)
      )
    end

    it "gets todo details" do
      todo_details = @client.todo.details(@todo[:id])
      expect(todo_details).to include(
        id: eq(@todo[:id]),
        title: eq("Updated Todo"),
        due_date: a_kind_of(String),
        created_at: a_kind_of(String),
        completed_at: nil,
        status: eq("Incomplete")
      )
    end

    it "lists all todos" do
      todos = @client.todo.list
      expect(todos).to include(
        {
          id: a_kind_of(Integer),
          title: a_kind_of(String),
          due_date: a_kind_of(String),
          created_at: a_kind_of(String),
          completed_at: a_kind_of(String),
          status: eq("Complete").or(eq("Incomplete")),
          notes_url: a_kind_of(String)
        }
      )
    end

    it "completes a todo" do
      completed_todo = @client.todo.complete(@todo[:id])
      expect(completed_todo).to include(status: 200)
    end
  end
end
