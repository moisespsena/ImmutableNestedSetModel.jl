# ImmutableNestedSetModel

[![Build Status](https://travis-ci.org/moisespsena/ImmutableNestedSetModel.jl.svg?branch=master)](https://travis-ci.org/moisespsena/ImmutableNestedSetModel.jl)

[![Coverage Status](https://coveralls.io/repos/moisespsena/ImmutableNestedSetModel.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/moisespsena/ImmutableNestedSetModel.jl?branch=master)

[![codecov.io](http://codecov.io/github/moisespsena/ImmutableNestedSetModel.jl/coverage.svg?branch=master)](http://codecov.io/github/moisespsena/ImmutableNestedSetModel.jl?branch=master)

Implements the [NestedSetModel](https://en.wikipedia.org/wiki/Nested_set_model) structure.

## Examples

```julia
using ImmutableNestedSetModel

convert(Tree, [
  ("ELECTRONICS", nothing),
  ("TELEVISIONS", "ELECTRONICS"),
  ("A", nothing),
  ("B", "ELECTRONICS"),
])

convert(Tree, KeyedTable(Dict(
  "ELECTRONICS" => ("ELECTRONICS", nothing),
  "TELEVISIONS" => ("TELEVISIONS", "ELECTRONICS"),
  "A" => ("A", nothing),
  "B" => ("B", "ELECTRONICS"),
), 2))

type E
  id
  parent
end

convert(Tree, StructItems([
  E("ELECTRONICS", nothing),
  E("TELEVISIONS", "ELECTRONICS"),
  E("A", nothing),
  E("B", "ELECTRONICS"),
], :id, :parent))

convert(Tree, StructTable(Dict(
  "ELECTRONICS" => E("ELECTRONICS", nothing),
  "TELEVISIONS" => E("TELEVISIONS", "ELECTRONICS"),
  "A" => E("A", nothing),
  "B" => E("B", "ELECTRONICS"),
), :parent))
```

