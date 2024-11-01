# frozen_string_literal: true

RSpec.describe "Issue Operations" do
  # Set up a test meeting and tear it down
  before(:all) do
    @client = Bloomy::Client.new
    @meeting_id = @client.meeting.create(title: "Test Meeting")[:meeting_id]
  end

  after(:all) do
    @client.meeting.delete(@meeting_id)
  end

  context "when managing issues" do
    it "creates, retrieves, and completes an issue" do
      # Create a new issue
      issue = @client.issue.create("Test Issue", @meeting_id)
      expect(issue[:title]).to eq("Test Issue")
      expect(issue[:meeting_id]).to eq(@meeting_id)

      # Get the details of the issue
      issue_id = issue[:id]
      details = @client.issue.details(issue_id)
      expect(details[:title]).to eq("Test Issue")
      expect(details[:meeting_details][:id]).to eq(@meeting_id)

      # Expect a completion
      @client.issue.complete(issue_id)
      details = @client.issue.details(issue_id)
      expect(details[:completed_at]).not_to be_nil
    end
  end
end
