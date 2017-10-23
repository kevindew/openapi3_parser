# Ideas for classes to represent OpenAPI

## Try to stay simple

- Fail early on invalid things
- Don't worry about versions other than 3.0


Public API should be just on OpenapiParser module

Document
- knows how to open a specification from:
  - input (string | hash)
  - local file
  - uri
- knows which openapi version
- knows the root object
- knows about includedocuments
- knows raw input

IncludeDocument

- knows about parent document
- knows raw input

Openapi

- extendable
- fields:
  - openapi, string, required
  - info, Info, required
  - servers, [Server]
  - paths, Paths, required
  - components, Components
  - security, [SecurityRequirement]
  - tags, [Tag]
  - externalDocs, ExternalDocumentation

Info

- extendable
- fields:
  - title, string, required
  - description, string (can be commonmark)
  - termsOfService, string
  - contact, Contact
  - license, License
  - version, string, required

Contact

- extendable
- fields:
  - name, string,
  - url, string (url)
  - email. string (email)

License

- extendable
- fields:
  - name, string, required
  - url, string (url)

Server
- extendable
- fields:
  - url, string (url, can be relative or have patterns), required
  - description, string (can be commonmark)
  - variables, Map<string, ServerVariableObject>

ServerVariable
- extendable
- fields:
  - enum: [String]
  - default, string, required
  - description, string (can be commonmark)

Components
- extendable
- fields:
  - schemas, Map<String, Schema|Reference>
  - responses, Map<String, Response|Reference>
  - parameters, Map<String, Parameter|Reference>
  - examples, Map<String, Example|Reference>
  - requestBodies, Map<String, RequestBody|Reference>
  - headers, Map<String, Header|Reference>
  - securitySchemes, Map<String, SecurityScheme|Reference>
  - links, Map<String, Link|Reference>
  - callbacks, Map<String, Callback|Reference>


