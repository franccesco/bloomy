# frozen_string_literal: true

RSpec.describe "Meeting Operations" do
  # Set up a test meeting and tear it down
  before(:all) do
    @client = Bloomy::Client.new
    @meeting_id = @client.meeting.create("Test Meeting", add_self: true)[:meeting_id]
  end

  after(:all) do
    @client.meeting.delete(@meeting_id)
  end
  context "when interacting with meetings API" do
    it "returns a list of meetings" do
      meetings = @client.meeting.list
      expect(meetings).to all(include(:id, :name))
    end

    it "returns a list of meeting attendees" do
      attendees = @client.meeting.attendees(@meeting_id)
      expect(attendees).to all(include(:name, :id))
    end

    it "returns a list of meeting issues" do
      issues = @client.meeting.issues(@meeting_id)
      expect(issues).to all(include(:id, :title, :created_at, :closed_at, :details_url, :owner))
    end

    it "returns a list of meeting todos" do
      todos = @client.meeting.todos(@meeting_id)
      expect(todos).to all(include(:id, :title, :due_date, :details_url, :completed_at, :owner))
    end

    it "returns a list of meeting measurables" do
      metrics = @client.meeting.metrics(@meeting_id)
      expect(metrics).to all(include(:id, :name, :target, :operator, :format, :owner, :admin))
    end

    it "returns meeting details" do
      details = @client.meeting.details(@meeting_id)
      expect(details).to include(:id, :title, :attendees, :issues, :todos, :metrics)
    end
  end
end
