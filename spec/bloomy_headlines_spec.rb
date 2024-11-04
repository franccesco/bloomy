# frozen_string_literal: true

RSpec.describe "Headline Operations" do
  # Set up a test meeting and tear it down
  before(:all) do
    @client = Bloomy::Client.new
    @meeting_id = @client.meeting.create(title: "Test Meeting")[:meeting_id]
  end

  after(:all) do
    @client.meeting.delete(@meeting_id)
  end

  # Create a headline before each test
  before(:each) do
    @headline_id = @client.headline.create(@meeting_id, "Test Headline")[:id]
  end

  context "when managing headlines" do
    it "creates a new headline" do
      expect(@headline_id).not_to be_nil
    end

    it "updates a headline" do
      status = @client.headline.update(@headline_id, "Updated Headline")
      expect(status).to be true
    end

    it "gets headline details" do
      headline = @client.headline.details(@headline_id)

      expect(headline[:title]).to eq("Test Headline")
      expect(headline[:meeting_details][:id]).to eq(@meeting_id)
      expect(headline[:meeting_details][:name]).to eq("Test Meeting")
    end

    it "gets user headlines" do
      headlines = @client.headline.user_headlines

      expect(headlines).not_to be_empty
    end

    it "deletes a headline" do
      status = @client.headline.delete(@meeting_id, @headline_id)

      expect(status).to be true
    end
  end
end
