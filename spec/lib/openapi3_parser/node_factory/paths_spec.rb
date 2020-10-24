# frozen_string_literal: true

require "support/node_object_factory"
require "support/helpers/context"

RSpec.describe Openapi3Parser::NodeFactory::Paths do
  include Helpers::Context

  it_behaves_like "node object factory", Openapi3Parser::Node::Paths do
    let(:input) do
      {
        "/pets" => {
          "get" => {
            "description" => "Returns all pets that the user has access to",
            "responses" => {
              "200" => {
                "description" => "A list of pets.",
                "content" => {
                  "application/json" => {
                    "schema" => {
                      "type" => "array",
                      "items" => { "type" => "string" }
                    }
                  }
                }
              }
            }
          }
        }
      }
    end

    let(:node_factory_context) { create_node_factory_context(input) }
    let(:node_context) do
      node_factory_context_to_node_context(node_factory_context)
    end
  end

  describe "path keys" do
    subject { described_class.new(create_node_factory_context(input)) }

    let(:path) do
      {
        "get" => {
          "description" => "Description",
          "responses" => {
            "200" => { "description" => "Description" }
          }
        }
      }
    end

    context "when the path key is a valid path" do
      let(:input) { { "/path" => path } }

      it { is_expected.to be_valid }
    end

    context "when the path key has template paramaters" do
      let(:input) { { "/path/{test}" => path } }

      it { is_expected.to be_valid }
    end

    context "when a path key does not begin with a slash" do
      let(:input) { { "path" => path } }

      it { is_expected.not_to be_valid }
    end

    context "when a path key is not a path" do
      let(:input) { { "invalid path" => path } }

      it { is_expected.not_to be_valid }
    end

    context "when there are two paths with same hiearchy but different "\
            "templated names" do
      let(:input) do
        {
          "/path/{param_a}/test" => path,
          "/path/{param_b}/test" => path
        }
      end

      it { is_expected.not_to be_valid }
    end
  end
end
