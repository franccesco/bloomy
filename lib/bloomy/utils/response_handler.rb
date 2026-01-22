# frozen_string_literal: true

module Bloomy
  module Utilities
    # Provides consistent response handling and error raising across all operations
    module ResponseHandler
      private

      # Handles API response, returning body on success or raising appropriate error
      #
      # @param response [Faraday::Response] the API response
      # @param context [String] description of the operation for error messages
      # @return [Hash, Array] the response body on success
      # @raise [AuthenticationError] when authentication fails (401/403)
      # @raise [NotFoundError] when resource is not found (404)
      # @raise [RateLimitError] when rate limited (429)
      # @raise [ApiError] for other API errors
      def handle_response(response, context:)
        return response.body if response.success?

        raise_error_for_status(response, context)
      end

      # Handles API response for operations that return boolean success
      #
      # @param response [Faraday::Response] the API response
      # @param context [String] description of the operation for error messages
      # @return [true] on success
      # @raise [AuthenticationError] when authentication fails (401/403)
      # @raise [NotFoundError] when resource is not found (404)
      # @raise [RateLimitError] when rate limited (429)
      # @raise [ApiError] for other API errors
      def handle_response!(response, context:)
        return true if response.success?

        raise_error_for_status(response, context)
      end

      # Raises appropriate error based on HTTP status code
      #
      # @param response [Faraday::Response] the API response
      # @param context [String] description of the operation for error messages
      # @raise [AuthenticationError, NotFoundError, RateLimitError, ApiError]
      def raise_error_for_status(response, context)
        status = response.status
        body = response.body

        case status
        when 401, 403
          raise AuthenticationError, "Authentication failed: #{context} (#{status})"
        when 404
          raise NotFoundError.new("Not found: #{context}", status: status, response_body: body)
        when 429
          retry_after = response.headers["Retry-After"]&.to_i
          raise RateLimitError.new("Rate limited: #{context}", retry_after: retry_after, status: status, response_body: body)
        else
          raise ApiError.new("Failed to #{context}: #{status}", status: status, response_body: body)
        end
      end
    end
  end
end
