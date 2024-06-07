# frozen_string_literal: true

RSpec.describe 'Measurable Operations' do
  let(:client) { Bloomy::Client.new }

  context 'when interacting with measurables API', :vcr do
    it 'returns the current week via API', :vcr do
      current_week = client.measurable.current_week
      expect(current_week).to include(
        {
          id: a_kind_of(Integer),
          week_number: a_kind_of(Integer),
          week_start: a_kind_of(String),
          week_end: a_kind_of(String)
        }
      )
    end

    it 'returns my current scorecard', :vcr do
      client.measurable.current_week
      scorecards = client.measurable.scorecard
      expect(scorecards).to include(
        {
          id: a_kind_of(Integer),
          title: a_kind_of(String),
          target: a_kind_of(Float),
          value: a_kind_of(Float).or(be_nil),
          updated_at: a_kind_of(String).or(be_nil),
          week_number: a_kind_of(Integer)
        }
      )
    end

    it "updates the current week's scorecard" do
      id_to_update = client.measurable.scorecard[0][:id]
      should_return_true = client.measurable.update(id_to_update, 3.0)
      expect(should_return_true).to be true
    end
  end
end
