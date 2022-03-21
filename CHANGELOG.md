# 0.9.2

- No longer require a specific Psych dependency to instead use Ruby stdlib

# 0.9.1

- Fix Schema#requires? incorrectly returning true for referenced properties -
  https://github.com/kevindew/openapi3_parser/issues/20
- Drop support for Ruby 2.5

# 0.9.0

- Fix unexpected fields error when using Example nodes inside a Parameter -
  https://github.com/kevindew/openapi3_parser/pull/19
- Drop support for Ruby 2.4

# 0.8.2

- Fix bug falling into recursive loop on Array/Map nodes -
  https://github.com/kevindew/openapi3_parser/issues/13

# 0.8.1

- Fix incorrectly spelt method name on `Schema` s/disciminator/discriminator/g

# 0.8.0

- Resolve deprecation warnings for Ruby 2.7
- Resolve deprecation warnings for Psych
- Operation and Path Item objects use servers that have cascaded from parent
  objects if they do not have their own servers defined.
- Add `#relative_node` and `#parent_node` methods to `Node::Context`.
- Default to a server of "/" when given an empty or null servers input for
  OpenAPI node.
- Set referenced data as input and source location for a PathItem with only
  a $ref value.
- Fix data being lost in PathItem reference merges.

# 0.7.0

- Add `#values` method to `Node::Object` and `Node#Map` to have a method that
  pairs with `#keys`
- Add `Node::Schema#requires?` method to simplify checking whether a property
  is required by a particular schema.
- Add `#==` methods to Node objects. This allows checking whether two nodes
  are from the same source location even if they're referenced in different
  places.
- Add `Node::Schema#name` method that looks up the name of a Schema based
  on it's contextual position in a document. Allows accessing the `Pet` value
  from `#/components/schemas/Pet`.

# 0.6.1

- Fix bug where Node::Object and Node::Map iterated arrays rather than hashes
  on #each and other Enumerable methods

# 0.6.0

- Drop support for Ruby 2.3
- Re-use references for significantly faster initialisation and validation
- Only error when accessing an invalid node rather than at root
- Handle infinitely recursive references that never resolve

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
