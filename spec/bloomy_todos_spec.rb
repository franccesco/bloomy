# frozen_string_literal: true

RSpec.describe Bloomy::TodoOperations do
  let(:client) { Bloomy::Client.new }
  let(:user_id) { client.get_my_user_id }

  context 'when interacting with todos API' do
    it 'returns user pending todos' do
      todos = client.get_todos(user_id: user_id)
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
