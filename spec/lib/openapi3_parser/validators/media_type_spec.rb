# frozen_string_literal: true

RSpec.describe Openapi3Parser::Validators::MediaType do
  describe ".call" do
    it "returns a message when a media type is invalid" do
      expect(described_class.call("not a media type"))
        .to eq %("not a media type" is not a valid media type)
    end

    it "returns nil for valid media types and ranges" do
      %w[
        */*
        text/*
        text/plain
        application/atom+xml
        application/EDI-X12
        application/xml-dtd
        application/zip
        application/vnd.openxmlformats-officedocument.presentationml
        video/quicktime
      ].each do |media_type|
        expect(described_class.call(media_type)).to be_nil
      end
    end
  end
end
