# frozen_string_literal: true

require 'bloomy'

RSpec.describe Bloomy do
  let(:username) { ENV['USERNAME'] }
  let(:password) { ENV['PASSWORD'] }
  let(:config_file) { File.expand_path('~/.bloomy/config.yaml') }
  let(:config) { Bloomy::Configuration.new }
  let(:client) { Bloomy::Client.new }

  it "has a version number" do
    expect(Bloomy::VERSION).not_to be nil
  end

  context "when configuring the API key" do
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

  context "when interacting with the API via the client" do
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

    it "returns the main user's direct reports" do
      direct_reports = client.get_direct_reports
      expect(direct_reports).to include(
        {
          name: a_kind_of(String),
          id: a_kind_of(Integer)
        }
      )
    end
  end
end
