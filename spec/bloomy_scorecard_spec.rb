# frozen_string_literal: true

RSpec.describe "Scorecard Operations" do
  before(:all) do
    @client = Bloomy::Client.new
  end

  context "when interacting with scorecard API" do
    it "returns current week details" do
      week = @client.scorecard.current_week
      expect(week).to be_a(Hash)
      expect(week[:id]).to be_a(Integer)
      expect(week[:week_number]).to be_a(Integer)
      expect(week[:week_start]).to be_a(String)
      expect(week[:week_end]).to be_a(String)
    end

    it "lists scorecards for the current user" do
      scorecards = @client.scorecard.list(show_empty: true)
      expect(scorecards).to be_an(Array)
      next if scorecards.empty?

      scorecard = scorecards.first
      expect(scorecard[:id]).to be_a(Integer)
      expect(scorecard[:measurable_id]).to be_a(Integer)
      expect(scorecard[:title]).to be_a(String)
    end

    it "lists scorecards with week_offset" do
      scorecards = @client.scorecard.list(show_empty: true, week_offset: 0)
      expect(scorecards).to be_an(Array)
    end

    it "gets a single scorecard by measurable_id" do
      scorecards = @client.scorecard.list(show_empty: true)
      next if scorecards.empty?

      measurable_id = scorecards.first[:measurable_id]
      scorecard = @client.scorecard.get(measurable_id: measurable_id)
      expect(scorecard).to be_a(Hash)
      expect(scorecard[:measurable_id]).to eq(measurable_id)
    end

    it "returns nil when measurable_id not found" do
      scorecard = @client.scorecard.get(measurable_id: 999_999_999)
      expect(scorecard).to be_nil
    end
  end
end
