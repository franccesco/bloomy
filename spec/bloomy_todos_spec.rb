# frozen_string_literal: true

RSpec.describe "Todo Operations" do
  let(:client) { Bloomy::Client.new }
  let(:user_id) { client.user.default_user_id }

  context "when interacting with todos API" do
    it "returns user pending todos" do
      todos = client.todo.list(user_id: user_id)
      expect(todos).to include(
        {
          id: a_kind_of(Integer),
          title: a_kind_of(String),
          due_date: a_kind_of(String),
          created_at: a_kind_of(String)
        }
      )
    end
  end
end
