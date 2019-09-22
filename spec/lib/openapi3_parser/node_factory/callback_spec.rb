# frozen_string_literal: true

require "support/node_object_factory"
require "support/helpers/context"

RSpec.describe Openapi3Parser::NodeFactory::Callback do
  include Helpers::Context

  it_behaves_like "node object factory", Openapi3Parser::Node::Callback do
    let(:callback_expression) do
      "http://notificationServer.com?transactionId={$request.body#/id}"\
      "&email={$request.body#/email}"
    end

    let(:input) do
      {
        callback_expression => {
          "post" => {
            "requestBody" => {
              "description" => "Callback payload",
              "content" => {
                "application/json" => {
                  "schema" => { "type" => "string" }
                }
              }
            },
            "responses" => {
              "200" => {
                "description" => "webhook successfully processed and no"\
                                 "retries will be performed"
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
end
