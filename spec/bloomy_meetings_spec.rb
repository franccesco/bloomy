RSpec.describe "Meeting Operations" do
  let(:client) { Bloomy::Client.new }
  let(:meeting_id) { ENV['MEETING_ID'] }

  context "when interacting with meetings API", :vcr do
    it "returns the meetings visible to the user", :vcr do
      meetings = client.get_meetings
      expect(meetings).to include(
        {
          id: a_kind_of(Integer),
          name: a_kind_of(String),
        }
      )
    end

    it "returns the attendees of a meeting", :vcr do
      attendees = client.get_meeting_attendees(meeting_id)
    end

    it "returns the issues attached to a meeting", :vcr do
      issues = client.get_meeting_issues(meeting_id, include_closed = true)
      expect(issues).to include(
        {
          id: a_kind_of(Integer),
          title: a_kind_of(String),
          created_at: a_kind_of(String),
          closed_at: a_kind_of(String).or(be_nil),
          owner: {
            id: a_kind_of(Integer),
            name: a_kind_of(String),
          }
        }
      )
    end
  end
end
