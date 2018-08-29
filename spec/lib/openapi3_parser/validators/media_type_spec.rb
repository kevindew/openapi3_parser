# frozen_string_literal: true

RSpec.describe Openapi3Parser::Validators::MediaType do
  describe ".call" do
    subject { described_class.call(media_type) }

    context "when input is not a media type" do
      let(:media_type) { "not an media type" }
      it { is_expected.to eq %("#{media_type}" is not a valid media type) }
    end

    context "when media type is valid" do
      let(:valid_media_types) do
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
        ]
      end

      it "doesn't return an error on any of them" do
        valid_media_types.each do |media_type|
          expect(described_class.call(media_type)).to be_nil
        end
      end
    end
  end
end
