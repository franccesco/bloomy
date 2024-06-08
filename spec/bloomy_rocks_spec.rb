# frozen_string_literal: true

RSpec.describe "Rock Operations" do
  let(:client) { Bloomy::Client.new }
  let(:user_id) { client.user.default_user_id }

  context "when interacting with rocks API" do
    it "returns user rocks" do
      rocks = client.rock.list(user_id: user_id)
      expect(rocks).to include(
        {
          id: a_kind_of(Integer),
          title: a_kind_of(String),
          created_at: a_kind_of(String),
          due_date: a_kind_of(String),
          status: eq("Completed").or(eq("Incomplete"))
        }
      )
    end

    it "returns user active & archived rocks" do
      rocks = client.rock.list(user_id: user_id, archived: true)
      expect(rocks).to include(
        {
          active: a_kind_of(Array),
          archived: a_kind_of(Array)
        }
      )
    end
  end
end
