# frozen_string_literal: true

# Class to handle all the operations related to users
class User
  attr_reader :default_user_id

  def initialize(conn)
    @conn = conn
    @default_user_id = current_user_id
  end

  def current_user_id
    response = @conn.get("users/mine").body
    response["Id"]
  end

  def details(user_id: @default_user_id, direct_reports: false, positions: false, all: false)
    response = @conn.get("users/#{user_id}").body
    user_details = {name: response["Name"], id: response["Id"], image_url: response["ImageUrl"]}

    user_details[:direct_reports] = direct_reports(user_id: user_id) if direct_reports || all
    user_details[:positions] = positions(user_id: user_id) if positions || all

    user_details
  end

  def direct_reports(user_id: @default_user_id)
    direct_reports_response = @conn.get("users/#{user_id}/directreports").body
    direct_reports_response.map { |report| {name: report["Name"], id: report["Id"], image_url: report["ImageUrl"]} }
  end

  def positions(user_id: @default_user_id)
    position_response = @conn.get("users/#{user_id}/seats").body
    position_response.map do |position|
      {name: position["Group"]["Position"]["Name"], id: position["Group"]["Position"]["Id"]}
    end
  end

  def search(term)
    response = @conn.get("search/user", term: term).body
    response.map do |user|
      {
        id: user["Id"],
        name: user["Name"],
        description: user["Description"],
        email: user["Email"],
        organization_id: user["OrganizationId"],
        image_url: user["ImageUrl"]
      }
    end
  end
end
