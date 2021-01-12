# frozen_string_literal: true

RSpec.describe "Iterate through a document" do
  let(:document) { Openapi3Parser.load(input) }

  let(:input) do
    {
      openapi: "3.0.0",
      info: {
        title: "Test Document",
        version: "1.0.0"
      },
      servers: [
        {
          url: "https://development.gigantic-server.com/v1",
          description: "Development server"
        },
        {
          url: "https://staging.gigantic-server.com/v1",
          description: "Staging server"
        },
        {
          url: "https://api.gigantic-server.com/v1",
          description: "Production server"
        }
      ],
      paths: {
        "/path": {
          get: {
            responses: {
              default: {
                description: "Get response",
                content: {
                  "application/json": {
                    example: "test"
                  }
                }
              }
            }
          }
        }
      },
      components: {
        schemas: {
          my_schema: {
            title: "My Schema"
          },
          my_other_schema: {
            title: "My Other Schema"
          }
        }
      }
    }
  end

  it "is a valid document" do
    expect(document).to be_valid
  end

  it "can iterate the root object" do
    keys = []
    values = []
    document.each do |k, v|
      keys << k
      values << v
    end

    expect(keys).to match_array %w[openapi
                                   info
                                   servers
                                   paths
                                   components
                                   security
                                   tags
                                   externalDocs]
    expected_values = [
      "3.0.0",
      an_instance_of(Openapi3Parser::Node::Info),
      an_instance_of(Openapi3Parser::Node::Array),
      an_instance_of(Openapi3Parser::Node::Paths),
      an_instance_of(Openapi3Parser::Node::Components),
      an_instance_of(Openapi3Parser::Node::Array),
      an_instance_of(Openapi3Parser::Node::Array),
      nil
    ]
    expect(values).to match_array(expected_values)
  end

  it "can iterate through a map" do
    schema_titles = document.components.schemas.map { |_k, v| v.title }

    expect(schema_titles).to eq ["My Schema", "My Other Schema"]

    schema_names = document.components.schemas.map(&:first)

    expect(schema_names).to eq %w[my_schema my_other_schema]
  end

  it "can iterate through an array" do
    expect(document.servers.count).to eq 3

    server_descriptions = document.servers.map(&:description)

    expect(server_descriptions).to eq ["Development server",
                                       "Staging server",
                                       "Production server"]
  end
end
