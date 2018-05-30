# frozen_string_literal: true

require "openapi3_parser/node_factory/callback"
require "openapi3_parser/node/callback"

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

    let(:context) { create_context(input) }
  end
end
