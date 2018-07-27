# frozen_string_literal: true

module Openapi3Parser
  class CautiousDig
    private_class_method :new

    def self.call(*args)
      new.call(*args)
    end

    def call(collection, *segments)
      segments.inject(collection) do |next_depth, segment|
        break unless next_depth

        if next_depth.respond_to?(:keys)
          hash_like(next_depth, segment)
        elsif next_depth.respond_to?(:[])
          array_like(next_depth, segment)
        end
      end
    end

    private

    def hash_like(item, segment)
      key = item.keys.find { |k| segment == k || segment.to_s == k.to_s }
      item[key]
    end

    def array_like(item, segment)
      index = if segment.is_a?(String) && segment =~ /\A\d+\z/
                segment.to_i
              else
                segment
              end
      index.is_a?(Integer) ? item[index] : nil
    end
  end
end
