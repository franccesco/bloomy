# frozen_string_literal: true

RSpec.describe 'Issue Operations' do
  let(:client) { Bloomy::Client.new }
  let(:meeting_id) { ENV['MEETING_ID'] }
  let(:issue_id) { ENV['ISSUE_ID'] }

  context 'when interacting with issues API' do
    it 'returns the correct issue details' do
      issue = client.get_issue(issue_id)
      expect(issue).to include(
        id: a_kind_of(Integer),
        title: a_kind_of(String),
        notes_url: a_kind_of(String),
        created_at: a_kind_of(String),
        completed_at: a_kind_of(String).or(be_nil),
        meeting_details: {
          id: a_kind_of(Integer),
          name: a_kind_of(String)
        },
        owner_details: {
          id: a_kind_of(Integer),
          name: a_kind_of(String)
        }
      )
    end

    it 'returns the correct issues for a user' do
      issues = client.get_user_issues
      expect(issues).to all(include(
                              id: a_kind_of(Integer),
                              title: a_kind_of(String),
                              notes_url: a_kind_of(String),
                              created_at: a_kind_of(String),
                              meeting_id: a_kind_of(Integer),
                              meeting_name: a_kind_of(String)
                            ))
    end

    it 'creates and completes an issue' do
      created_issue = client.create_issue('Test issue', meeting_id)
      expect(created_issue).to include(
        {
          id: a_kind_of(Integer),
          title: a_kind_of(String)
        }
      )
      completed_issue = client.complete_issue(created_issue[:id])
      expect(completed_issue).to be true
    end
  end
end
