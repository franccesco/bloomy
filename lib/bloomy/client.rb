require 'faraday'

module Bloomy
  class Client
    attr_reader :configuration

    def initialize
      @configuration = Configuration.new
      @base_url = 'https://app.bloomgrowth.com/api/v1'
      @conn = Faraday.new(url: @base_url) do |faraday|
        faraday.response :json
        faraday.adapter Faraday.default_adapter
        faraday.headers['Accept'] = 'application/json'
        faraday.headers['Authorization'] = "Bearer #{configuration.api_key}"
      end
      @user_id = nil
    end

    def configure
      yield(configuration)
    end

    def get_user_details
      response = @conn.get('users/mine').body
    end

    def get_direct_reports
      response = @conn.get('users/minedirectreports').body
      direct_reports = response.map { |report| { name: report['Name'], id: report['Id'] } }
    end

    def get_meetings
      response = @conn.get('L10/list').body
      meetings = response.map { |meeting| { id: meeting['Id'], name: meeting['Name'] } }
    end
  end
end
