# frozen_string_literal: true

module Bloomy
  module Types
    TodoItem = Struct.new(
      :id,
      :title,
      :notes_url,
      :due_date,
      :created_at,
      :completed_at,
      :status,
      :user_name,
      :user_id,
      keyword_init: true
    )

    HeadlineItem = Struct.new(
      :id,
      :title,
      :notes_url,
      :meeting_details,
      :owner_details,
      :archived,
      :created_at,
      :closed_at,
      keyword_init: true
    )

    MeetingItem = Struct.new(
      :id,
      :title,
      keyword_init: true
    )

    MeetingDetails = Struct.new(
      :id,
      :title,
      :attendees,
      :issues,
      :todos,
      :metrics
    )

    MetricItem = Struct.new(
      :id,
      :title,
      :target,
      :operator,
      :format,
      :user_id,
      :user_name,
      :admin_id,
      :admin_name,
      keyword_init: true
    )

    UserItem = Struct.new(
      :id,
      :name,
      :image_url,
      :email,
      :description,
      :organization_id,
      :position,
      :direct_reports,
      :positions,
      keyword_init: true
    )

    GoalItem = Struct.new(
      :id,
      :title,
      :created_at,
      :due_date,
      :status,
      :meeting_id,
      :meeting_title,
      :user_id,
      :user_name,
      keyword_init: true
    )

    IssueItem = Struct.new(
      :id,
      :title,
      :notes_url,
      :created_at,
      :completed_at,
      :meeting_id,
      :meeting_title,
      :user_id,
      :user_name,
      keyword_init: true
    )

    IssueDetails = Struct.new(
      :id,
      :title,
      :notes_url,
      :created_at,
      :completed_at,
      :meeting_details,
      :owner_details,
      keyword_init: true
    )

    WeekItem = Struct.new(
      :id,
      :week_number,
      :week_start,
      :week_end,
      keyword_init: true
    )

    ScorecardItem = Struct.new(
      :id,
      :measurable_id,
      :accountable_user_id,
      :title,
      :target,
      :value,
      :week,
      :week_id,
      :updated_at,
      keyword_init: true
    )
  end
end
