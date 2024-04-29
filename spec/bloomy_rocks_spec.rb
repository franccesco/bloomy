# frozen_string_literal: true

RSpec.describe Bloomy::RockOperations do
  let(:client) { Bloomy::Client.new }
  let(:user_id) { client.get_my_user_id }

  context 'when interacting with rocks API' do
    it 'returns user rocks' do
      rocks = client.get_rocks(user_id: user_id)
      expect(rocks).to include(
        {
          id: a_kind_of(Integer),
          title: a_kind_of(String),
          created_at: a_kind_of(String),
          due_date: a_kind_of(String),
          status: eq('Completed').or(eq('Incomplete'))
        }
      )
    end

    it 'returns user archived rocks' do
      archived_rocks = client.get_archived_rocks(user_id: user_id)
      expect(archived_rocks).to include(
        {
          id: a_kind_of(Integer),
          title: a_kind_of(String),
          created_at: a_kind_of(String),
          due_date: a_kind_of(String),
          status: eq('Completed').or(eq('Incomplete'))
        }
      )
    end
  end
end
