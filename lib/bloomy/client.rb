require 'faraday'
require_relative 'operations/users'
require_relative 'operations/meetings'
require_relative 'operations/rocks'
require_relative 'operations/todos'
require_relative 'operations/measurables'
require_relative 'operations/issues'

module Bloomy
  class Client
    include UserOperations,
            MeetingOperations,
            RockOperations,
            TodoOperations,
            MeasurableOperations,
            IssueOperations
    attr_reader :configuration

    def initialize
      @configuration = Configuration.new
      @base_url = 'https://app.bloomgrowth.com/api/v1'
      @conn = Faraday.new(url: @base_url) do |faraday|
        faraday.response :json
        faraday.adapter Faraday.default_adapter
        faraday.headers['Accept'] = '*/*'
        faraday.headers['Content-Type'] = 'application/json'
        faraday.headers['Authorization'] = "Bearer #{configuration.api_key}"
      end
      @user_id = nil
    end

    def configure
      yield(configuration)
    end
  end
end
