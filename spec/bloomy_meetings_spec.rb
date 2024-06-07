# frozen_string_literal: true

RSpec.describe "Meeting Operations" do
  let(:client) { Bloomy::Client.new }
  let(:user_id) { client.user.default_user_id }
  let(:meeting_id) { client.meeting.list(user_id: user_id).first[:id] }
  let(:title) { "Test Meeting" }
  let(:attendees) { [ENV["ATTENDEE_ID"].to_i] }

  context "when interacting with meetings API" do
    it "returns a list of meetings" do
      meetings = client.meeting.list(user_id: user_id)
      expect(meetings).to all(include(:id, :name))
    end

    it "returns a list of meeting attendees" do
      attendees = client.meeting.attendees(meeting_id)
      expect(attendees).to all(include(:name, :id))
    end

    it "returns a list of meeting issues" do
      issues = client.meeting.issues(meeting_id)
      expect(issues).to all(include(:id, :title, :created_at, :closed_at, :details_url, :owner))
    end

    it "returns a list of meeting todos" do
      todos = client.meeting.todos(meeting_id)
      expect(todos).to all(include(:id, :title, :due_date, :details_url, :completed_at, :owner))
    end

    it "returns a list of meeting measurables" do
      metrics = client.meeting.metrics(meeting_id)
      expect(metrics).to all(include(:id, :name, :target, :operator, :format, :owner, :admin))
    end

    it "returns meeting details" do
      details = client.meeting.details(meeting_id)
      expect(details).to include(:id, :name, :attendees, :issues, :todos, :metrics)
    end

    it "creates and deletes a meeting with a title, adds self and adds attendees" do
      # Creates a meeting
      response = client.meeting.create(title: title, add_self: true, attendees: attendees)
      expect(response).to include(:meeting_id, :title, :attendees)
      expect(response[:title]).to eq(title)
      expect(response[:attendees]).to include(*attendees)

      # Deletes the meeting
      meeting_id = response[:meeting_id]
      delete_response = client.meeting.delete(meeting_id)
      expect(delete_response.status).to eq(200)
    end

    it "Creates a meeting with no attendees" do
      # Creates a meeting
      response = client.meeting.create(title: title)
      expect(response).to include(:meeting_id, :title, :attendees)
      expect(response[:title]).to eq(title)
      expect(response[:attendees]).to be_empty

      # Deletes the meeting
      meeting_id = response[:meeting_id]
      delete_response = client.meeting.delete(meeting_id)
      expect(delete_response.status).to eq(200)
    end
  end
end
