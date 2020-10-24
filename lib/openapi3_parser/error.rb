# frozen_string_literal: true

module Openapi3Parser
  # An abstract class for Exceptions produced by this Gem
  class Error < ::RuntimeError
    # Raised in cases where we have been provided a path or URL to a file and
    # at runtime when we have tried to access that resource it is not available
    # for whatever reason.
    class InaccessibleInput < Error; end

    # Raised in cases where we provided data that we expected to be parsable
    # (such as a string of JSON data) but when we tried to parse it an error
    # is raised
    class UnparsableInput < Error; end

    # Raised in cases where an object that is in an immutable state is modified
    #
    # Typically this would occur when a component that is frozen is modififed.
    # Some components are mutable during the construction of a document and
    # then frozen afterwards.
    class ImmutableObject < Error; end

    # Raised when a node is provided data as a type that is outside the allowed
    # list
    class InvalidType < Error; end

    # Raised when we have to abort creating an object due to invalid data
    class InvalidData < Error; end

    # Used when there are fields that are missing from an object which prevents
    # us from creating a node
    class MissingFields < Error; end

    # Used when there are extra fields that are not expected in the data for
    # a node
    class UnexpectedFields < Error; end

    # Used when a method we expect to be able to call (through symbol or proc)
    # is not callable
    class NotCallable < Error; end

    # Raised when we in a recursive data structure and can't perform an
    # operation
    class InRecursiveStructure < Error; end

    # Used when we're trying to validate that a type is something that is not
    # validatable, most likely a sign that we're in a bug
    class UnvalidatableType < Error; end
  end
end
