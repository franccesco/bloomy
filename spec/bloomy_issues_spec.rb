RSpec.describe "Issue Operations" do
  let(:client) { Bloomy::Client.new }
  let(:meeting_id) { ENV['MEETING_ID'] }
  context "when interacting with issues API", :vcr do
    it "returns my issues", :vcr do
      my_issues = client.get_my_issues
      expect(my_issues).to include(
        {
          id: a_kind_of(Integer),
          title: a_kind_of(String),
          notes_url: a_kind_of(String),
          created_at: a_kind_of(String),
          completed_at: a_kind_of(String).or(be_nil),
          meeting_id: a_kind_of(Integer),
          meeting_name: a_kind_of(String),
        }
      )
    end

    it "creates and completes an issue", :vcr do
      # Create an issue
      created_issue = client.create_issue("Test issue", meeting_id)
      expect(created_issue).to include(
        {
          id: a_kind_of(Integer),
          title: a_kind_of(String),
        }
      )

      # Complete the created issue
      completed_issue = client.complete_issue(created_issue[:id])
      expect(completed_issue).to be true
    end
  end
end
