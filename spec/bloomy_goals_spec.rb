# frozen_string_literal: true

RSpec.describe "Goal Operations" do
  before(:all) do
    @client = Bloomy::Client.new
    @meeting_details = @client.meeting.create("Test Meeting")
    @created_goal = @client.goal.create(title: "Test Goal", meeting_id: @meeting_details[:meeting_id])
  end

  after(:all) do
    @client.meeting.delete(@meeting_details[:meeting_id])
  end

  context "when interacting with goals API" do
    it "returns user goals" do
      goals = @client.goal.list
      expect(goals).to include(
        {
          id: a_kind_of(Integer),
          title: a_kind_of(String),
          created_at: a_kind_of(String),
          due_date: a_kind_of(String),
          status: eq("Completed").or(eq("Incomplete")),
          meeting_id: a_kind_of(Integer),
          meeting_title: a_kind_of(String)
        }
      )
    end

    it "returns user active & archived goals" do
      goals = @client.goal.list(archived: true)
      expect(goals).to include(
        {
          active: a_kind_of(Array),
          archived: a_kind_of(Array)
        }
      )
    end

    it "tests the created goal" do
      expect(@created_goal).to include(
        {
          goal_id: a_kind_of(Integer),
          title: a_kind_of(String),
          meeting_id: a_kind_of(Integer),
          meeting_title: a_kind_of(String),
          user_id: a_kind_of(Integer),
          user_name: a_kind_of(String),
          created_at: a_kind_of(String)
        }
      )

      expect { DateTime.parse(@created_goal[:created_at]) }.not_to raise_error
    end

    it "updates the created goal" do
      response = @client.goal.update(goal_id: @created_goal[:goal_id], title: "On Goal", status: "on")
      expect(response).to be true
      response = @client.goal.update(goal_id: @created_goal[:goal_id], title: "Off Goal", status: "off")
      expect(response).to be true
      response = @client.goal.update(goal_id: @created_goal[:goal_id], title: "Complete Goal", status: "complete")
      expect(response).to be true
    end

    it "archives the created goal" do
      # Archive the goal
      response = @client.goal.archive(@created_goal[:goal_id])
      expect(response).to be true

      # Verify goal appears in archived list
      goals = @client.goal.list(archived: true)
      expect(goals[:archived]).to include(hash_including(id: @created_goal[:goal_id]))
    end

    it "restores the archived goal" do
      # Restore the goal
      response = @client.goal.restore(@created_goal[:goal_id])
      expect(response).to be true

      # Verify goal appears in active list
      goals = @client.goal.list(archived: true)
      expect(goals[:active]).to include(hash_including(id: @created_goal[:goal_id]))
    end

    it "deletes the created goal" do
      response = @client.goal.delete(@created_goal[:goal_id])
      expect(response).to be true
    end
  end
end
