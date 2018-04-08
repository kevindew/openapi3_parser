# frozen_string_literal: true

module Openapi3Parser
  module Validators
    class AbsoluteUri
      def self.call(input)
        uri = URI.parse(input)
        %("#{input}" is not a absolute URI) unless uri.absolute?
      rescue URI::InvalidURIError
        %("#{input}" is not a valid URI)
      end
    end
  end
end
