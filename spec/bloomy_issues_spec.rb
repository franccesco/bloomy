# frozen_string_literal: true

RSpec.describe "Issue Operations" do
  before(:all) do
    @client = Bloomy::Client.new
    @meeting_id = @client.meeting.create("Test Meeting")[:meeting_id]
    @issue = @client.issue.create(meeting_id: @meeting_id, title: "Test Issue", notes: "Note!")
    @issue_id = @issue[:id]
  end

  after(:all) do
    @client.meeting.delete(@meeting_id)
  end

  context "when managing issues" do
    it "creates an issue" do
      expect(@issue[:title]).to eq("Test Issue")
      expect(@issue[:meeting_id]).to eq(@meeting_id)
    end

    it "retrieves an issue" do
      details = @client.issue.details(@issue_id)
      expect(details[:title]).to eq("Test Issue")
      expect(details[:meeting_id]).to eq(@meeting_id)
      expect(details[:notes_url]).not_to be_nil
    end

    it "lists user issues" do
      issues = @client.issue.list
      expect(issues).to be_an_instance_of(Array)
      expect(issues).not_to be_empty
      expect(issues.first).to be_a(Hash)
    end

    it "lists meeting issues" do
      issues = @client.issue.list(meeting_id: @meeting_id)
      expect(issues).to be_an_instance_of(Array)
      expect(issues).not_to be_empty
      expect(issues.first).to be_a(Hash)
    end

    it "updates an issue title" do
      updated = @client.issue.update(issue_id: @issue_id, title: "Updated Issue Title")
      expect(updated).to be_a(Hash)
      expect(updated[:title]).to eq("Updated Issue Title")
    end

    it "raises ArgumentError when no fields provided" do
      expect { @client.issue.update(issue_id: @issue_id) }.to raise_error(ArgumentError)
    end

    it "solves an issue" do
      response = @client.issue.solve(@issue_id)
      expect(response).to be true
    end
  end

  context "error handling" do
    it "raises ApiError for invalid issue ID" do
      expect { @client.issue.details(999999999) }.to raise_error(Bloomy::ApiError)
    end

    it "raises ArgumentError when providing both user_id and meeting_id" do
      expect { @client.issue.list(user_id: 1, meeting_id: 1) }.to raise_error(ArgumentError)
    end
  end
end
