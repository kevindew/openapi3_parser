# frozen_string_literal: true

RSpec.describe "Default servers through a document" do
  let(:document) { Openapi3Parser.load(input) }

  let(:input) do
    {
      openapi: "3.0.0",
      info: {
        title: "Test Document",
        version: "1.0.0"
      },
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
            },
            servers: operation_servers
          },
          servers: path_item_servers
        }
      },
      servers: openapi_servers
    }
  end

  let(:openapi_servers) { [] }
  let(:path_item_servers) { [] }
  let(:operation_servers) { [] }

  context "when no servers are defined" do
    it "has the default servers on the Openapi object" do
      expect(document.servers.first.url).to eq "/"
      expect(document.servers.first.description).to be_nil
    end

    it "has the same servers on Openapi, Path Item and Operation objects" do
      expect(document.paths["/path"].servers).to eq document.servers
      expect(document.paths["/path"].get.servers).to eq document.servers
    end
  end

  context "when servers are defined on the Openapi object" do
    let(:openapi_servers) { [{ url: "/openapi", description: "Openapi" }] }

    it "has the defined server on the Openapi object" do
      expect(document.servers.first.url).to eq "/openapi"
      expect(document.servers.first.description).to eq "Openapi"
    end

    it "has the same servers on Openapi, Path Item and Operation objects" do
      expect(document.paths["/path"].servers).to eq document.servers
      expect(document.paths["/path"].get.servers).to eq document.servers
    end
  end

  context "when servers are defined on the Path Item object" do
    let(:path_item_servers) { [{ url: "/path", description: "Path" }] }

    it "has the same servers on Path Item and Operation objects" do
      path_item_servers = document.paths["/path"].servers
      expect(path_item_servers.first.url).to eq "/path"
      expect(path_item_servers.first.description).to eq "Path"
      expect(document.paths["/path"].get.servers).to eq path_item_servers
    end

    it "has the default servers on the Openapi object" do
      expect(document.servers.first.url).to eq "/"
      expect(document.servers.first.description).to be_nil
    end
  end

  context "when servers are defined on the Operation object" do
    let(:operation_servers) do
      [{ url: "/operation", description: "Operation" }]
    end

    it "has the servers on the Operation object" do
      operation_servers = document.paths["/path"].get.servers
      expect(operation_servers.first.url).to eq "/operation"
      expect(operation_servers.first.description).to eq "Operation"
    end

    it "has the default servers on the Openapi and Path Item objects" do
      expect(document.servers.first.url).to eq "/"
      expect(document.servers.first.description).to be_nil
      expect(document.paths["/path"].servers).to eq document.servers
    end
  end
end
