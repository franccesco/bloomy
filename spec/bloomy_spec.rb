# frozen_string_literal: true

RSpec.describe Bloomy do
  let(:username) { ENV['USERNAME'] }
  let(:password) { ENV['PASSWORD'] }
  let(:meeting_id) { ENV['MEETING_ID'] }
  let(:config_file) { File.expand_path('~/.bloomy/config.yaml') }
  let(:config) { Bloomy::Configuration.new }
  let(:client) { Bloomy::Client.new }

  it "has a version number" do
    expect(Bloomy::VERSION).not_to be nil
  end

  context "when configuring the API key", :vcr do
    before do
      File.delete(config_file) if File.exist?(config_file)
      config.configure_api_key(username, password, true)
    end

    it "returns an API key" do
      expect(config.api_key).not_to be nil
    end

    it "stores the API key in ~/.bloomy/config.yaml" do
      expect(File.exist?(config_file)).to be true
    end

    it "loads the stored API key" do
      loaded_config = YAML.load_file(config_file)
      expect(loaded_config[:api_key]).not_to be nil
    end
  end

  context "when interacting with the API via the client", :vcr do
    it "returns the main user's details" do
      user_details = client.get_user_details
          expect(user_details).to include(
            "Id" => a_kind_of(Integer),
            "Type" => a_kind_of(String),
            "Key" => a_kind_of(String),
            "Name" => a_kind_of(String),
            "ImageUrl" => a_kind_of(String)
          )
    end

    it "returns the main user's direct reports", :vcr do
      direct_reports = client.get_direct_reports
      expect(direct_reports).to include(
        {
          name: a_kind_of(String),
          id: a_kind_of(Integer)
        }
      )
    end

    it "returns the meetings visible to the user", :vcr do
      meetings = client.get_meetings
      expect(meetings).to include(
        {
          id: a_kind_of(Integer),
          name: a_kind_of(String),
        }
      )
    end

    it "returns the attendees of a meeting", :vcr do
      attendees = client.get_meeting_attendees(meeting_id)
    end

    it "returns the issues attached to a meeting", :vcr do
      issues = client.get_meeting_issues(meeting_id, include_closed = true)
      expect(issues).to include(
        {
          id: a_kind_of(Integer),
          title: a_kind_of(String),
          created_at: a_kind_of(String),
          closed_at: a_kind_of(String).or(be_nil),
          owner: {
            id: a_kind_of(Integer),
            name: a_kind_of(String),
          }
        }
      )
    end

    it "returns my rocks", :vcr do
      rocks = client.get_my_rocks
      expect(rocks).to include(
        {
          id: a_kind_of(Integer),
          title: a_kind_of(String),
          created_at: a_kind_of(String),
          due_date: a_kind_of(String),
          status: eq('Completed').or(eq('Incomplete'))
        }
      )
    end

    it "returns my archived rocks", :vcr do
      archived_rocks = client.get_my_archived_rocks
      expect(archived_rocks).to include(
        {
          id: a_kind_of(Integer),
          title: a_kind_of(String),
          created_at: a_kind_of(String),
          due_date: a_kind_of(String),
          status: eq('Completed').or(eq('Incomplete'))
        }
      )
    end
  end
end
