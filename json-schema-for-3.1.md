# JSON schema with 3.1

Temporary document to be removed with the merge of support for OpenAPI 3.1

Things have got complex with schemas in OpenAPI 3.1

How things might work:

- when a schema factory is created, it determines whether the dialect is supported
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

$ref - in 3.0
$dynamicRef
$defs
$schema
$id
$comment
$anchor
$dynamicAnchor

Then a ton of fields:

type: string - in 3.0
enum: array - in 3.0
const: any type - done
multipleOf: number - in 3.0
maximum: number - in 3.0
exclusiveMaximum: number - done
minimum: number - in 3.0
exclusiveMinimum: number - done
maxLength: integer >= 0 - in 3.0 (missing >= val)
minLength: integer >= 0 - in 3.0
pattern: string - in 3.0
maxItems: integer >= 0 - in 3.0
minItems: integer >= 0 - in 3.0
uniqueItems: boolean - in 3.0
maxContains: integer >= 0 - done
minContains: integer >= 0 - done
maxProperties: integer >= 0 - in 3.0
minProperties: integer >= 0 - in 3.0
required: array, strings, unique - in 3.0 (missing unique)
dependentRequired: something complex
contentEncoding: string - done
contentMediaType: string / media type - done
contentSchema: schema - done
title: string - in 3.0
description: string - in 3.0
default: any - in 3.0
deprecated: boolean (default false) - in 3.0
readOnly: boolean (default false) - in 3.0
writeOnly: boolean (default false) - in 3.0
examples: array - done
format: any - in 3.0

allOf - non empty array of schemas - in 3.0
anyOf - non empty array of schemas - in 3.0
oneOf - non empty array of schemas - in 3.0
not - schema - in 3.0

if - single schema - done
then - single schema - done
else - single schema - done
dependentSchemas - map of schemas - somewhat complex, is it related to dependentRequired ?

prefixItems: array of schema - done
items: array of schema - in 3.0
contains: schema - done

properties: object, each value json schema - in 3.0
patternProperties: object each value JSON schema key regex - done
additionalProperties: single json schema

unevaluatedItems - single schema
unevaluatedProperties: single schema


## Returning to this in 2025

Assumption: it'll be extremely rare for usage of the advanced schema fields like dynamicRefs and dynamicAnchors, let's see what we can implement that meets most use cases and hopefully doesn't crash on complex ones

Current idea is create a Schema::Common which can share methods between both schema objects that are shared, then add distinctions for differences

At point of shutting down on 10th January 2025 I was wondering about how schemas merge. I also decided to defer thinking about referenceable node object factory.

I learnt that merging seems largely undefined in JSON Schema, as far as I can tell and I'm just going with a strategy of most recent field wins.

I've set up a Node::Schema class for common schema methods and Node::Schema::v3_0 and v3_1Up classes for specific changes. Need to flesh out
tests and then behaviour that differs between them.

Little things:
- schema integer fields generally are required to be non-negative
- quite common for arrays to be invalid if not unique (required, type)
- probably want a quick way to get coverage of the methods on nodes
- could validate that pattern and patternProperties contain regexs

JSON Schema specs:

meta: https://datatracker.ietf.org/doc/html/draft-bhutton-json-schema-00
validation: https://datatracker.ietf.org/doc/html/draft-bhutton-json-schema-validation-00
