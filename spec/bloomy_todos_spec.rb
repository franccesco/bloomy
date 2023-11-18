RSpec.describe "Todo Operations" do
  let(:client) { Bloomy::Client.new }

  context "when interacting with todos API", :vcr do
    it "returns my pending todos", :vcr do
      todos = client.get_my_todos
      expect(todos).to include(
        {
          id: a_kind_of(Integer),
          title: a_kind_of(String),
          due_date: a_kind_of(String),
          created_at: a_kind_of(String),
        }
      )
    end
  end
end
