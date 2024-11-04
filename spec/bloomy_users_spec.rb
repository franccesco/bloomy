# frozen_string_literal: true

RSpec.describe "User Operations" do
  before(:all) do
    @client = Bloomy::Client.new
  end

  context "when interacting with the users API" do
    it "returns the basic user details" do
      user_details = @client.user.details
      expect(user_details).to include(
        name: a_kind_of(String),
        id: a_kind_of(Integer),
        image_url: a_kind_of(String)
      )
      expect(user_details).not_to have_key(:direct_reports)
      expect(user_details).not_to have_key(:positions)
    end

    it "returns the user details with direct reports" do
      user_details = @client.user.details(direct_reports: true)
      expect(user_details).to include(
        name: a_kind_of(String),
        id: a_kind_of(Integer),
        image_url: a_kind_of(String),
        direct_reports: a_kind_of(Array)
      )
    end

    it "returns the user details with positions" do
      user_details = @client.user.details(positions: true)
      expect(user_details).to include(
        name: a_kind_of(String),
        id: a_kind_of(Integer),
        image_url: a_kind_of(String),
        positions: a_kind_of(Array)
      )
    end

    it "returns the direct reports of the user" do
      direct_reports = @client.user.direct_reports
      expect(direct_reports).to all(include(
        name: a_kind_of(String),
        id: a_kind_of(Integer),
        image_url: a_kind_of(String)
      ))
    end

    it "returns the positions of the user" do
      positions = @client.user.positions
      expect(positions).to all(include(
        name: a_kind_of(String),
        id: a_kind_of(Integer)
      ))
    end

    it "returns the users that match the search term" do
      users = @client.user.search("fran")
      expect(users).to all(include(
        id: a_kind_of(Integer),
        name: a_kind_of(String),
        description: a_kind_of(String),
        email: a_kind_of(String),
        organization_id: a_kind_of(Integer),
        image_url: a_kind_of(String)
      ))
    end
  end
end
