require 'json'

module Bloomy
  module IssueOperations
    def get_my_issues
      response = @conn.get('issues/users/mine').body
      issues = response.map do |issue|
        {
          id: issue['Id'],
          title: issue['Name'],
          notes_url: issue['DetailsUrl'],
          created_at: issue['CreateTime'],
          completed_at: issue['CompleteTime'],
          meeting_id: issue['OriginId'],
          meeting_name: issue['Origin']
        }
      end
    end

    def complete_issue(issue_id)
      response = @conn.post("issues/#{issue_id}/complete", { complete: true }.to_json).status
      response == 200
    end

    def create_issue(issue_title, meeting_id)
      response = @conn.post('issues/create', { title: issue_title, meetingid: meeting_id }.to_json)
      {
        id: response.body['Id'],
        title: response.body['Name']
      }
    end
  end
end
