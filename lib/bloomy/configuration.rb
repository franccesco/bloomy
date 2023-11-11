require 'fileutils'
require 'faraday'
require 'yaml'

module Bloomy
  class Configuration
    attr_accessor :api_key

    def initialize
      @api_key = ENV['API_KEY']
    end

    def configure_api_key(username, password, store_key=false)
      if @api_key.nil?
        conn = Faraday.new(url: 'https://app.bloomgrowth.com') do |faraday|
          faraday.request :url_encoded
          faraday.adapter Faraday.default_adapter
        end

        response = conn.post do |req|
          req.url '/Token'
          req.headers['Content-Type'] = 'application/x-www-form-urlencoded'
          req.body = "grant_type=password&userName=#{username}&password=#{password}"
        end

        @api_key = JSON.parse(response.body)['access_token']
        if store_key
          store_api_key
        end
      end
    end

    # Store the api_key in a file in ~/.bloomy using a YAML format like this:
    # version: 1
    # api_key: <api_key>
    def store_api_key
      if @api_key.nil?
        raise "API key is nil"
      else
        FileUtils.mkdir_p(File.expand_path('~/.bloomy'))
        File.open(File.expand_path('~/.bloomy/config.yaml'), 'w') do |f|
          f.write({version: 1, api_key: @api_key}.to_yaml)
        end
      end
    end
  end
end
