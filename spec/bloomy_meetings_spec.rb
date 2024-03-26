# FILEPATH: /Users/fran/workspace/bloomy/spec/bloomy_meeting_operations_spec.rb

RSpec.describe Bloomy::MeetingOperations do
  let(:client) { Bloomy::Client.new }
  let(:user_id) { client.get_my_user_id }
  let(:meeting_id) { client.get_meetings(user_id: user_id).first[:id] }

  context "when interacting with meetings API" do
    it "returns a list of meetings" do
      meetings = client.get_meetings(user_id: user_id)
      expect(meetings).to all(include(:id, :name))
    end

    it "returns a list of meeting attendees" do
      attendees = client.get_meeting_attendees(meeting_id)
      expect(attendees).to all(include(:name, :id))
    end

    it "returns a list of meeting issues" do
      issues = client.get_meeting_issues(meeting_id)
      expect(issues).to all(include(:id, :title, :created_at, :closed_at, :details_url, :owner))
    end

    it "returns a list of meeting todos" do
      todos = client.get_meeting_todos(meeting_id)
      expect(todos).to all(include(:id, :title, :due_date, :details_url, :completed_at, :owner))
    end

    it "returns a list of meeting measurables" do
      measurables = client.get_meeting_measurables(meeting_id)
      expect(measurables).to all(include(:id, :name, :target, :operator, :format, :owner, :admin))
    end

    it "returns meeting details" do
      details = client.get_meeting_details(meeting_id)
      expect(details).to include(:id, :name, :attendees, :issues, :todos, :measurables)
    end
  end
end
