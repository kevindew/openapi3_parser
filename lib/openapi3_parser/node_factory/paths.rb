# frozen_string_literal: true

require "openapi3_parser/node_factory/map"

module Openapi3Parser
  module NodeFactory
    class Paths < NodeFactory::Map
      PATH_REGEX = %r{
        \A
        # required prefix slash
        /
        (
          # Match a path
          ([\-;_.!~*'()a-zA-Z\d:@&=+$,]|%[a-fA-F\d]{2})*
          # Match a path template parameter
          ({([\-;_.!~*'()a-zA-Z\d:@&=+$,]|%[a-fA-F\d]{2})+})*
          # optional segment separating slash
          /?
        )*
        \Z
      }x.freeze

      def initialize(context)
        factory = NodeFactory::OptionalReference.new(NodeFactory::PathItem)

        super(context,
              allow_extensions: true,
              value_factory: factory,
              validate: :validate)
      end

      private

      def build_node(data, node_context)
        Node::Paths.new(data, node_context)
      end

      def validate(validatable)
        paths = validatable.input.keys.grep_v(NodeFactory::EXTENSION_REGEX)
        validate_paths(validatable, paths)
      end

      def validate_paths(validatable, paths)
        invalid_paths = paths.reject { |p| PATH_REGEX.match(p) }
        unless invalid_paths.empty?
          joined = invalid_paths.map { |p| "'#{p}'" }.join(", ")
          validatable.add_error("There are invalid paths: #{joined}")
        end

        conflicts = conflicting_paths(paths)

        return if conflicts.empty?

        joined = conflicts.map { |p| "'#{p}'" }.join(", ")
        validatable.add_error("There are paths that conflict: #{joined}")
      end

      def conflicting_paths(paths)
        potential_conflicts = paths.each_with_object({}) do |path, memo|
          without_params = path.gsub(/{.*?}/, "")
          memo[path] = without_params if path != without_params
        end

        grouped_paths = potential_conflicts.group_by(&:last)
                                           .map { |_k, v| v.map(&:first) }

        grouped_paths.select { |group| group.size > 1 }.flatten
      end
    end
  end
end
