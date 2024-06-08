# frozen_string_literal: true

RSpec.describe "Rock Operations" do
  before(:all) do
    @client = Bloomy::Client.new
    @user_id = @client.user.default_user_id
    @meeting_details = @client.meeting.create(title: "Test Meeting")
    @created_rock = @client.rock.create(title: "Test Rock", user_id: @user_id, meeting_id: @meeting_details[:meeting_id])
  end

  after(:all) do
    @client.meeting.delete(@meeting_details[:meeting_id])
  end

  context "when interacting with rocks API" do
    it "returns user rocks" do
      rocks = @client.rock.list(user_id: @user_id)
      expect(rocks).to include(
        {
          id: a_kind_of(Integer),
          title: a_kind_of(String),
          created_at: a_kind_of(String),
          due_date: a_kind_of(String),
          status: eq("Completed").or(eq("Incomplete")),
          meeting_id: a_kind_of(Integer),
          meeting_name: a_kind_of(String)
        }
      )
    end

    it "returns user active & archived rocks" do
      rocks = @client.rock.list(user_id: @user_id, archived: true)
      expect(rocks).to include(
        {
          active: a_kind_of(Array),
          archived: a_kind_of(Array)
        }
      )
    end

    it "tests the created rock" do
      expect(@created_rock).to include(
        {
          rock_id: a_kind_of(Integer),
          title: a_kind_of(String),
          meeting_id: a_kind_of(Integer),
          meeting_name: a_kind_of(String),
          user_id: a_kind_of(Integer),
          user_name: a_kind_of(String),
          created_at: a_kind_of(DateTime)
        }
      )
    end

    it "updates the created rock" do
      response = @client.rock.update(rock_id: @created_rock[:rock_id], title: "Updated Rock")
      expect(response).to include(status: 200)
    end

    it "deletes the created rock" do
      response = @client.rock.delete(@created_rock[:rock_id])
      expect(response).to include(status: 200)
    end
  end
end
