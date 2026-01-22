# frozen_string_literal: true

require "bloomy/utils/response_handler"

module Bloomy
  module Utilities
    module UserIdUtility
      include ResponseHandler

      # Lazy loads the user_id of the default user
      #
      # @return [String] the user_id of the default user
      # @raise [AuthenticationError] when authentication fails
      # @raise [ApiError] when the API request fails
      def user_id
        @user_id ||= default_user_id
      end

      private

      # Returns the user_id of the default user
      #
      # @return [String] The user_id of the default user
      # @raise [AuthenticationError] when authentication fails
      # @raise [ApiError] when the API request fails
      def default_user_id
        response = @conn.get("users/mine")
        data = handle_response(response, context: "get current user")
        data.dig("Id")
      end
    end
  end
end
