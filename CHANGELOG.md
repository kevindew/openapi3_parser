# 0.5.2

- Fix outputting warnings for cyclic dependencies and undefined variables -
  fixes: https://github.com/kevindew/openapi3_parser/issues/6
- Add Date and Time to YAML safe classes so library doesn't crash on an
  unquoted timestamp - fixes: https://github.com/kevindew/openapi3_parser/issues/7

# 0.5.1

- Bugfix for allowing maps to have extension like field names

# 0.5.0

- Support for recursive references - fixes: https://github.com/kevindew/openapi3_parser/issues/4
- `node_at` method on nodes and document to allow looking up nodes by string
  paths
- Refactor of the node factory classes to use simpler inheritance rather than
  the mixins in mixins approach.

# 0.4.0

- Determine the OpenAPI specification version and store it in document.
- Support commonmark rendering, add description_html methods to nodes which
  allow description to be rendered as HTML.
- Fix bug with CGI constant unresolved

# 0.3.0

- Allow opening files by URL
- Support references in different files

# 0.2.0

- Allow defaulting to empty arrays and maps
- Configure rubydoc
- Types returned documented for the nodes

