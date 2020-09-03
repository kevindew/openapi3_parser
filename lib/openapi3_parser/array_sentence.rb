# frozen_string_literal: true

module Openapi3Parser
  module ArraySentence
    refine ::Array do
      def sentence_join
        return join if count < 2

        "#{self[0..-2].join(', ')} and #{self[-1]}"
      end
    end
  end
end
