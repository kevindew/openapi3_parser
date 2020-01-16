# frozen_string_literal: true

module Openapi3Parser
  module Validators
    class MediaType
      REGEX = %r{
        \A
        (\w+|\*) # word or asterisk
        / # separating slash
        ([-+.\w]+|\*) # word (with +, - & .) or asterisk
        \Z
      }x.freeze

      def self.call(input)
        message = %("#{input}" is not a valid media type)
        message unless REGEX.match(input)
      end
    end
  end
end
