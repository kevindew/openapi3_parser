# frozen_string_literal: true

module Helpers
  module SourceInput
    def create_file_source_input(data: {},
                                 path: "/path/to/openapi.yaml",
                                 working_directory: nil)
      allow(File)
        .to receive(:read)
        .with(path)
        .and_return(data.to_yaml)
      Openapi3Parser::SourceInput::File
        .new(path, working_directory: working_directory)
    end

    def create_raw_source_input(data: {},
                                base_url: nil,
                                working_directory: nil)
      Openapi3Parser::SourceInput::Raw
        .new(data,
             base_url: base_url,
             working_directory: working_directory)
    end

    def create_url_source_input(data: {},
                                url: "https://example.com/openapi.yaml")
      stub_request(:get, url)
        .to_return(body: data.to_yaml, status: 200)
      Openapi3Parser::SourceInput::Url.new(url)
    end
  end
end
