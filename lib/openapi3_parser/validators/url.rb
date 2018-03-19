# frozen_string_literal: true

module Openapi3Parser
  module Validators
    class Url
      def self.call(input)
        message = %("#{input}" is not a valid URL)
        uri = URI.parse(input)

        message if !uri.relative? &&
                   !uri.is_a?(URI::HTTP) &&
                   !uri.is_a?(URI::HTTPS)
      rescue URI::InvalidURIError
        message
      end
    end
  end
end
