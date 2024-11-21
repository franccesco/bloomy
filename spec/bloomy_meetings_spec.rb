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
      expect(meetings).to all(be_a(MeetingItem))
      expect(meetings.first).to have_attributes(
        id: be_kind_of(Integer),
        title: be_kind_of(String)
      )
    end

    it "returns a list of meeting attendees" do
      attendees = @client.meeting.attendees(@meeting_id)
      expect(attendees).to all(be_a(MeetingAttendee))
      expect(attendees.first).to have_attributes(
        id: be_kind_of(Integer),
        name: be_kind_of(String)
      )
    end

    it "returns a list of meeting issues" do
      issues = @client.meeting.issues(@meeting_id)
      expect(issues).to all(include(:id, :title, :created_at, :closed_at, :details_url, :owner))
    end

    it "returns a list of meeting todos" do
      todos = @client.meeting.todos(@meeting_id)
      expect(todos).to all(include(:id, :title, :due_date, :details_url, :completed_at, :owner))
    end

    it "returns a list of meeting metrics" do
      metrics = @client.meeting.metrics(@meeting_id)
      expect(metrics).to all(be_a(MeetingMetric))

      # Skip detailed attribute checking if no metrics exist
      if metrics.any?
        expect(metrics.first).to have_attributes(
          id: be_kind_of(Integer),
          title: be_kind_of(String),
          target: be_kind_of(Numeric),
          operator: be_kind_of(String),
          format: be_kind_of(String),
          owner: be_a(UserItem),
          admin: be_a(UserItem)
        )
      end
    end

    it "returns meeting details" do
      details = @client.meeting.details(@meeting_id)
      expect(details).to be_a(MeetingDetails)
      expect(details).to have_attributes(
        id: be_kind_of(Integer),
        title: be_kind_of(String),
        attendees: all(be_a(MeetingAttendee)),
        issues: be_kind_of(Array),
        todos: be_kind_of(Array),
        metrics: all(be_a(MeetingMetric))
      )
    end
  end
end
