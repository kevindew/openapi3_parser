# Todo

These are the steps defined to reach 1.0. Assistance is very welcome.

- [ ] Handle mutually exclusive fields
- [ ] Refactor the various NodeFactory modules to be a less confusing
      hierachical structure. Consider having factories subclass instead of use
      mixin
- [x] Decouple Document class for the source file. Consider a source file class
      instead
- [x] Validate that a reference creates the type of node that is expected in
      a context
- [x] Allow opening of references from additional files
- [x] Allow opening of openapi documents by URL
- [x] Support references by URL
- [ ] Consider option to limit open by URL/path behaviour
- [ ] Support converting CommonMark to HTML
- [ ] Reach parity with OpenAPI specification for validation
- [ ] Consider a lenient mode for a document to only have to comply with type
      based validation
- [ ] Improve test coverage
- [ ] Publish documentation of the interface through the structure
- [x] Consider a resolved context class for representing context with a node
      that can handle scenarios where a node is represented by both a reference
      and resolved context
- [ ] Create error classes for various scenarios
- [ ] Associate/resolve operation id / operation references
- [ ] Do something to model expressions
- [x] Improve the modelling of namespace
- [ ] Set up nicer string representations of key classes to help them be
      debugged
- [x] Ensure Array and Map nodes return empty ones by default rather than nil
