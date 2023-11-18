RSpec.describe "Rock Operations" do
  let(:client) { Bloomy::Client.new }

  context "when interacting with rocks API", :vcr do
    it "returns my rocks", :vcr do
      rocks = client.get_my_rocks
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

    it "returns my archived rocks", :vcr do
      archived_rocks = client.get_my_archived_rocks
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
