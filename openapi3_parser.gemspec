# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "openapi3_parser/version"

Gem::Specification.new do |spec|
  spec.name          = "openapi3_parser"
  spec.version       = Openapi3Parser::VERSION
  spec.author        = "Kevin Dew"
  spec.email         = "kevindew@me.com"
  spec.metadata      = { "rubygems_mfa_required" => "true" }

  spec.summary       = "An OpenAPI V3 parser for Ruby"
  spec.description   = <<-DESCRIPTION
    A tool to parse and validate OpenAPI V3 files.
    Aims to provide complete compatibility with the OpenAPI specification and
    to provide a natural, idiomatic way to interact with a openapi.yaml file.
  DESCRIPTION
  spec.homepage      = "https://github.com/kevindew/openapi_parser"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^spec/})
  end

  spec.required_ruby_version = ">= 3.1"

  # Require version than 0.23.6 as earlier versions are susceptible to GHSA-4qw4-jpp4-8gvp
  spec.add_dependency "commonmarker", "~> 0.23", ">= 0.23.6"
end
