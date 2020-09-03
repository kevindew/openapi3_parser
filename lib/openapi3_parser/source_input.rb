# frozen_string_literal: true

module Openapi3Parser
  # An abstract class which is used to provide a foundation for classes that
  # represent the different means of input an OpenAPI document can have. It is
  # used to represent the underlying source of the data which is used as a
  # source within an OpenAPI document.
  #
  # @see SourceInput::Raw   SourceInput::Raw for an input that is done through
  #                         data, such as a Hash.
  #
  # @see SourceInput::File  SourceInput::File for an input that is done through
  #                         the path to a file within the local file system.
  #
  # @see SourceInput::Url   SourceInput::Url for an input that is done through]
  #                         a URL to an OpenAPI Document
  #
  # @attr_reader [Error::InaccessibleInput, nil]  access_error
  # @attr_reader [Error::UnparsableInput, nil]    parse_error
  class SourceInput
    attr_reader :access_error, :parse_error

    def initialize
      return if access_error

      @contents = parse_contents
    rescue ::StandardError => e
      @parse_error = Error::UnparsableInput.new(e.message)
    end

    # Indicates that the data within this input is suitable (i.e. can parse
    # underlying JSON or YAML) for trying to use as part of a Document
    def available?
      access_error.nil? && parse_error.nil?
    end

    # For a given reference use the context of the current SourceInput to
    # determine which file is required for the reference. This allows
    # references to use relative file paths because we can combine them witt
    # the current SourceInput location to determine the next one
    def resolve_next(_reference); end

    # Used to determine whether a different instance of SourceInput is
    # the same file/data
    def ==(_other); end

    # The parsed data from the input
    #
    # @raise [Error::InaccessibleInput] In cases where the file does not exist
    # @raise [Error::UnparsableInput]   In cases where the data is not parsable
    #
    # @return Object
    def contents
      raise access_error if access_error
      raise parse_error if parse_error

      @contents
    end

    # The relative path, if possible, for this source_input compared to a
    # different one. Defaults to empty string and should be specialised in
    # subclasses
    #
    # @return [String]
    def relative_to(_source_input)
      ""
    end
  end
end
