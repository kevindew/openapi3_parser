# JSON schema with 3.1

Temporary document to be removed with the merge of support for OpenAPI 3.1

Things have got complex with schemas in OpenAPI 3.1

How things might work:

- when a schema factory is created, it determines whether the dialect is suported
- it then creates a factory based on the dialect
- if there is a reference in it this is resolved
- there could be complexities in the resolving process because of the id field - does it become relative to this?
- skip dynamicAnchor and dynamicRef for now - they are quite complex: https://stackoverflow.com/questions/69728686/explanation-of-dynamicref-dynamicanchor-in-json-schema-as-opposed-to-ref-and
- lets allow extra properties for schema since it's complex
- there's all the $defs stuff but this might just work as being a type of reference - presumably not used in OpenAPI anyway really

So how might we start:

- Perhaps add a class method to Schema which can identify which Schema factory is used: a OAS 3.1 one, an optionally referenced OAS 3.0 one, or non optional reference (if such a need exists), based on context. Error if given an unexpected dialect
- Learn whether you have to care about $id for resolving
- Create a node factory for OAS 3.1 Schema:
  - allow arbitrary fields perhaps? Probably not needed, just a pain to keep up with JsonSchema
  - load a merged reference
  - perhaps have context support a merge concept for source location
- Think about dealing with recursive defined as "#"

Dealing with the new JSON Schema approach for OpenAPI 3.1.

There is some meta fields:

$ref
$dynamicRef
$defs
$schema
$id
$comment
$anchor
$dynamicAnchor

Then a ton of fields:

type: string
enum: array
const: any type
multipleOf: number
maximum: number
exclusiveMaximum: number
minimum: number
exclusiveMinimum: number
maxLength: integer >= 0
minLength: integer >= 0
pattern: string
maxItems: integer >= 0
minItems: integer >= 0
uniqueItems: boolean
maxContains: integer >= 0
minContains: integer >= 0
maxProperties: integer >= 0
minProperties: integer >= 0
required: array, strings, unique
dependentRequired: something complex
contentEncoding: string
contentMediaType: string / media type
contentSchema: schema
title: string
description: string
default: any
deprecated: boolean (default false)
readOnly: boolean (default false)
writeOnly: boolean (default false)
examples: array


allOf - non empty array of schemas
anyOf - non empty array of schemas
oneOf - non empty array of schemas
not - schema

if - single schema
then - single schema
else - single schema

prefixItems: schema
items: schema
contains: schema

properties: object, each value json schema
patternProperties: object each value JSON schema
additionalProperties: single json schema

unevaluatedItems - single schema
unevaluatedProperties: single schema
