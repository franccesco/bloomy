# frozen_string_literal: true

require 'bloomy'

RSpec.describe Bloomy do
  let(:username) { ENV['USERNAME'] }
  let(:password) { ENV['PASSWORD'] }
  let(:config) { Bloomy::Configuration.new }

  it "has a version number" do
    expect(Bloomy::VERSION).not_to be nil
  end

  context "when configuring the API key" do
    before do
      config.configure_api_key(username, password, true)
    end

    it "returns an API key" do
      expect(config.api_key).not_to be nil
    end

    it "stores the API key in ~/.bloomy/config.yaml" do
      expect(File.exist?(File.expand_path('~/.bloomy/config.yaml'))).to be true
    end

    it "loads the stored API key" do
      loaded_config = YAML.load_file(File.expand_path('~/.bloomy/config.yaml'))
      expect(loaded_config[:api_key]).not_to be nil
    end
  end
end
