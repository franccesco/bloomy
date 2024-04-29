# frozen_string_literal: true

RSpec.describe 'Config Operations' do
  let(:username) { ENV['USERNAME'] }
  let(:password) { ENV['PASSWORD'] }
  let(:config_file) { File.expand_path('~/.bloomy/config.yaml') }
  let(:config) { Bloomy::Configuration.new }

  context 'when configuring the API key', :vcr do
    before do
      File.delete(config_file) if File.exist?(config_file)
      config.configure_api_key(username, password, true)
    end

    it 'returns an API key' do
      expect(config.api_key).not_to be nil
    end

    it 'stores the API key in ~/.bloomy/config.yaml' do
      expect(File.exist?(config_file)).to be true
    end

    it 'loads the stored API key' do
      loaded_config = YAML.load_file(config_file)
      expect(loaded_config[:api_key]).not_to be nil
    end
  end
end
