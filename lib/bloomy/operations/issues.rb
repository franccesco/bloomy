# frozen_string_literal: true

require 'json'

module Bloomy
  module IssueOperations
    include Bloomy::UserOperations

    def get_issue(issue_id)
      response = @conn.get("issues/#{issue_id}").body
      {
        id: response['Id'],
        title: response['Name'],
        notes_url: response['DetailsUrl'],
        created_at: response['CreateTime'],
        completed_at: response['CloseTime'],
        meeting_details: {
          id: response['OriginId'],
          name: response['Origin']
        },
        owner_details: {
          id: response['Owner']['Id'],
          name: response['Owner']['Name']
        }
      }
    end

    def get_user_issues(user_id: get_my_user_id)
      response = @conn.get("issues/users/#{user_id}").body
      response.map do |issue|
        {
          id: issue['Id'],
          title: issue['Name'],
          notes_url: issue['DetailsUrl'],
          created_at: issue['CreateTime'],
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
