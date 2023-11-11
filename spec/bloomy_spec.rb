# frozen_string_literal: true

username = ENV['USERNAME'].freeze
password = ENV['PASSWORD'].freeze
config = Bloomy::Configuration.new

RSpec.describe Bloomy do
  it "has a version number" do
    expect(Bloomy::VERSION).not_to be nil
  end

  it "returns an API key using Bloomy::Configuration.get_api_key" do
    config.configure_api_key(username, password)
    api_key = config.api_key
    expect(api_key).not_to be nil
  end

  # It should expect an api_key was stored in a YAML file in ~/.bloomy/config.yaml
  # After calling config.store_api_key
  it "stores the API key in ~/.bloomy/config.yaml" do
    config.store_api_key
    loaded_config = YAML.load_file(File.expand_path('~/.bloomy/config.yaml'))
    expect(File.exist?(File.expand_path('~/.bloomy/config.yaml'))).to be true
    expect(loaded_config[:api_key]).not_to be nil
  end
end
