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
  end
end
