__precompile__()

module ImmutableNestedSetModel

export Node, AnyNode, root, prepare, parents, parentscount, NodeIterator,
  Tree, iter, StructItems, KeyedItems, Table, KeyedTable, StructTable

import DataStructures: OrderedDict

include("types/Node.jl")
include("types/Tree.jl")

end # module
