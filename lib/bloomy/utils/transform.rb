# frozen_string_literal: true

require "date"
require "active_support/core_ext/hash/indifferent_access"

module Bloomy
  module Utilities
    # Provides consistent response transformation across all operations.
    # Handles date parsing and wraps hashes with indifferent access.
    module Transform
      # Fields that should be parsed as DateTime objects
      DATE_FIELDS = %i[
        due_date created_at completed_at closed_at updated_at week_start week_end
      ].freeze

      # Transforms a hash response with date parsing and indifferent access
      #
      # @param hash [Hash, nil] the hash to transform
      # @return [HashWithIndifferentAccess, nil] the transformed hash or nil
      # @example
      #   transform_response({ created_at: "2024-06-10" })
      #   #=> { "created_at" => #<DateTime: 2024-06-10...> }
      def transform_response(hash)
        return nil if hash.nil?

        result = parse_dates(hash)
        HashWithIndifferentAccess.new(result)
      end

      # Transforms an array of hashes
      #
      # @param array [Array<Hash>] the array of hashes to transform
      # @return [Array<HashWithIndifferentAccess>] the transformed array
      # @example
      #   transform_array([{ id: 1 }, { id: 2 }])
      #   #=> [{ "id" => 1 }, { "id" => 2 }]
      def transform_array(array)
        return [] if array.nil?

        array.map { |item| transform_response(item) }
      end

      private

      # Recursively parses date fields in a hash
      #
      # @param hash [Hash] the hash to parse
      # @return [Hash] the hash with parsed dates
      def parse_dates(hash)
        hash.transform_values do |value|
          case value
          when Hash
            parse_dates(value)
          else
            value
          end
        end.tap do |result|
          DATE_FIELDS.each do |field|
            result[field] = try_parse_date(result[field]) if result.key?(field)
          end
        end
      end

      # Attempts to parse a string value as a DateTime
      #
      # @param value [Object] the value to parse
      # @return [DateTime, Object] the parsed DateTime or original value
      def try_parse_date(value)
        return value unless value.is_a?(String) && !value.empty?

        DateTime.parse(value)
      rescue ArgumentError
        value
      end
    end
  end
end
