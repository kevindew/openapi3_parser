# Ideas on handling likes to operations

Operations are properties of of path items. We want to add methods to get the
path information from an operation as they don't offer much value outside that
context.

## operationId

These can be something that is only a concern of the current OpenAPI document.
We need to validate that there aren't any collisions between the operationId
values of Operation objects.

To do this an individual operation needs to know all of the other operationId
values. One (somewhat hacky) idea of handling this is to apply this validation
at the paths level where we have the whole collection. Another approach would
be to provide an operation object with some context at initialisation so this
data can be pulled out.

To validate that links all resolve to operationId mean they'll need access to
information too, either at initialisation or by doing these checks at a higher
level. As link objects can be references in components it is less clear how
this could be done.

## operationRef

For these the referenced object is pretty useless without path information
which may mean that for an external one we need to work out what other
information is needed from the external document for this to be useful.

This could be a big rabbit hole :-/

