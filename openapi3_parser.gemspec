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

  spec.required_ruby_version = ">= 2.6.0"

  spec.add_dependency "commonmarker", "~> 0.17"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "byebug", "~> 11.0"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 3.9"
  spec.add_development_dependency "rubocop", "~> 1"
  spec.add_development_dependency "rubocop-rake", "~> 0.5"
  spec.add_development_dependency "rubocop-rspec", "~> 2"
  spec.add_development_dependency "simplecov", "~> 0.19"
  spec.add_development_dependency "webmock", "~> 3.8"
end
