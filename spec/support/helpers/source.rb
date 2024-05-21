# frozen_string_literal: true

module Helpers
  module Source
    def create_source_location(source_input,
                               document: nil,
                               pointer_segments: [])
      source = create_source(source_input, document:)
      Openapi3Parser::Source::Location.new(source, pointer_segments)
    end

    def create_source(source_input, document: nil)
      unless source_input.is_a?(Openapi3Parser::SourceInput)
        source_input = Openapi3Parser::SourceInput::Raw.new(source_input)
      end

      if document
        registry = Openapi3Parser::Document::ReferenceRegistry.new
        Openapi3Parser::Source.new(source_input, document, registry)
      else
        Openapi3Parser::Document.new(source_input).root_source
      end
    end

    def create_file_source_input(data: {},
                                 path: "/path/to/openapi.yaml",
                                 working_directory: nil)
      allow(File)
        .to receive(:read)
        .with(path)
        .and_return(data.to_yaml)
      Openapi3Parser::SourceInput::File
        .new(path, working_directory:)
    end

    def create_raw_source_input(data: {},
                                base_url: nil,
                                working_directory: nil)
      Openapi3Parser::SourceInput::Raw
        .new(data,
             base_url:,
             working_directory:)
    end

    def create_url_source_input(data: {},
                                url: "https://example.com/openapi.yaml")
      stub_request(:get, url)
        .to_return(body: data.to_yaml, status: 200)
      Openapi3Parser::SourceInput::Url.new(url)
    end
  end
end
