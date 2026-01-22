# frozen_string_literal: true

module Bloomy
  # Base error class for all Bloomy errors
  class Error < StandardError; end

  # Raised when authentication fails (401/403)
  class AuthenticationError < Error; end

  # Base class for API errors with status and response body
  class ApiError < Error
    attr_reader :status, :response_body

    def initialize(message, status: nil, response_body: nil)
      @status = status
      @response_body = response_body
      super(message)
    end
  end

  # Raised when a requested resource is not found (404)
  class NotFoundError < ApiError; end

  # Raised when rate limited (429)
  class RateLimitError < ApiError
    attr_reader :retry_after

    def initialize(message, retry_after: nil, **kwargs)
      @retry_after = retry_after
      super(message, **kwargs)
    end
  end
end
