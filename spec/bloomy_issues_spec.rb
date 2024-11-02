# frozen_string_literal: true

RSpec.describe "Issue Operations" do
  # Set up a test meeting and tear it down
  before(:all) do
    @client = Bloomy::Client.new
    @meeting_id = @client.meeting.create(title: "Test Meeting")[:meeting_id]
    @issue = @client.issue.create(meeting_id: @meeting_id, title: "Test Issue")
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
      expect(details[:meeting_details][:id]).to eq(@meeting_id)
    end

    it "completes an issue" do
      @client.issue.complete(@issue_id)
      details = @client.issue.details(@issue_id)
      expect(details[:completed_at]).not_to be_nil
    end
  end
end
