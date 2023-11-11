require 'fileutils'
require 'faraday'
require 'yaml'

module Bloomy
  class Configuration
    attr_accessor :api_key

    def initialize
      @api_key = ENV['API_KEY'] || load_api_key
    end

    def configure_api_key(username, password, store_key=false)
      return unless @api_key.nil?

      @api_key = fetch_api_key(username, password)
      store_api_key if store_key
    end

    private

    def fetch_api_key(username, password)
      conn = Faraday.new(url: 'https://app.bloomgrowth.com')
      response = conn.post('/Token', "grant_type=password&userName=#{username}&password=#{password}", {'Content-Type' => 'application/x-www-form-urlencoded'})
      JSON.parse(response.body)['access_token']
    end

    def store_api_key
      raise "API key is nil" if @api_key.nil?

      FileUtils.mkdir_p(config_dir)
      File.write(config_file, {version: 1, api_key: @api_key}.to_yaml)
    end

    def load_api_key
      return nil unless File.exist?(config_file)

      YAML.load_file(config_file)[:api_key]
    end

    def config_dir
      File.expand_path('~/.bloomy')
    end

    def config_file
      File.join(config_dir, 'config.yaml')
    end
  end
end
