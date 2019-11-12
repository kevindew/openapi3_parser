# Todo

These are the steps defined to reach 1.0. Assistance is very welcome.

- [x] Handle mutually exclusive fields
- [x] Refactor the various NodeFactory modules to be a less confusing
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
- [x] Support converting CommonMark to HTML
- [ ] Reach parity with OpenAPI specification for validation
- [ ] Consider a lenient mode for a document to only have to comply with type
      based validation
- [x] Improve test coverage
- [ ] Publish documentation of the interface through the structure
- [x] Consider a resolved context class for representing context with a node
      that can handle scenarios where a node is represented by both a reference
      and resolved context
- [x] Create error classes for various scenarios
- [ ] Associate/resolve operation id / operation references
- [ ] Do something to model expressions
- [x] Improve the modelling of namespace
- [x] Set up nicer string representations of key classes to help them be
      debugged
- [x] Ensure Array and Map nodes return empty ones by default rather than nil
- [ ] Make JSON pointer public access to be consistent accepting string, array
      or (potentially) a pointer class
- [x] Support creating a default Server object on servers property of OpenAPI
      Node
- [ ] Support relative URLs being able to be relative the first server object
      see: https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.1.md#relative-references-in-urls
- [ ] Support validating a Server URL based on default values
- [ ] Validate paths to check path parameters within them appear in paths
      see: https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.1.md#fixed-fields-10
