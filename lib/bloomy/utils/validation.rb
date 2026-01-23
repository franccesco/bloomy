# frozen_string_literal: true

module Bloomy
  module Utilities
    # Provides input validation helpers for all operations.
    module Validation
      # Validates that a title is present and not empty
      #
      # @param title [String, nil] the title to validate
      # @param context [String] the context for error messages (default: "title")
      # @raise [ArgumentError] if title is nil or empty
      # @example
      #   validate_title!("My Todo")  # passes
      #   validate_title!(nil)        # raises ArgumentError
      #   validate_title!("")         # raises ArgumentError
      def validate_title!(title, context: "title")
        raise ArgumentError, "#{context} cannot be nil" if title.nil?
        raise ArgumentError, "#{context} cannot be empty" if title.to_s.strip.empty?
      end

      # Validates that an ID is a positive integer
      #
      # @param id [Object] the ID to validate
      # @param context [String] the context for error messages (default: "id")
      # @raise [ArgumentError] if ID is not a positive integer
      # @example
      #   validate_id!(123)           # passes
      #   validate_id!(0)             # raises ArgumentError
      #   validate_id!(-1)            # raises ArgumentError
      #   validate_id!("abc")         # raises ArgumentError
      def validate_id!(id, context: "id")
        raise ArgumentError, "#{context} must be a positive integer" unless id.is_a?(Integer) && id > 0
      end
    end
  end
end
