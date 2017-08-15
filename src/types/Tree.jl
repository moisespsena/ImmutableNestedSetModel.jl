include(joinpath(dirname(@__FILE__), "Tree0" * (VERSION < v"0.6-" ? "5" : "6") * ".jl"))

Tree{T}(::Type{T}) = Tree(Node(Void, T, nothing))
AnyTree() = Tree(Any)
Tree() = AnyTree()

StructItems(items::Vector; idfield::Symbol = :id, parentfield::Symbol = :parent) = StructItems(items, idfield, parentfield)

KeyedTable{K, V}(data::Associative{K, V}, key) = Table{K, V}(data, e -> e[key])
StructTable{K, V}(data::Associative{K, V}, field::Symbol) = Table{K, V}(data, e -> getfield(e, field))

newnode{T}(::Tree{T}, data::T) = Node(T, T, data)
nodetype{T}(t::Tree{T}) = Node{T, T}

"""
  convert(Tree, items::Table{K, T})::Tree{T}

Converts a table to Tree.

# Examples

```jldoctest
julia> convert(Tree, KeyedTable(Dict(
                "ELECTRONICS" => ("ELECTRONICS", nothing),
                "TELEVISIONS" => ("TELEVISIONS", "ELECTRONICS"),
                "A" => ("A", nothing),
                "B" => ("B", "ELECTRONICS"),
              ), 2))
ImmutableNestedSetModel.Tree{Any}:
 1  2  ("A",nothing)
 3  8  ("ELECTRONICS",nothing)
 4  5  - ("B","ELECTRONICS")
 6  7  - ("TELEVISIONS","ELECTRONICS")


julia> type E
          id
          parent
       end

julia> convert(Tree, StructItems([
               E("ELECTRONICS", nothing),
               E("TELEVISIONS", "ELECTRONICS"),
               E("A", nothing),
               E("B", "ELECTRONICS"),
             ], :id, :parent))
ImmutableNestedSetModel.Tree{E}:
 1  2  E("A",nothing)
 3  8  E("ELECTRONICS",nothing)
 4  5  - E("B","ELECTRONICS")
 6  7  - E("TELEVISIONS","ELECTRONICS")


julia> convert(Tree, StructTable(Dict(
                  "ELECTRONICS" => E("ELECTRONICS", nothing),
                  "TELEVISIONS" => E("TELEVISIONS", "ELECTRONICS"),
                  "A" => E("A", nothing),
                  "B" => E("B", "ELECTRONICS"),
                ), :parent))
ImmutableNestedSetModel.Tree{E}:
 1  2  E("A",nothing)
 3  8  E("ELECTRONICS",nothing)
 4  5  - E("B","ELECTRONICS")
 6  7  - E("TELEVISIONS","ELECTRONICS")

```
"""
Base.convert{K, T}(::Type{Tree}, items::Table{K, T}) = prepare(append!(Tree(T), items))

"""
  convert(Tree, items::StructItems{T})::Tree{T}

Converts a StructItems to Tree.

# Examples

```jldoctest
julia> type E
          id
          parent
       end

julia> convert(Tree, StructItems([
               E("ELECTRONICS", nothing),
               E("TELEVISIONS", "ELECTRONICS"),
               E("A", nothing),
               E("B", "ELECTRONICS"),
             ], :id, :parent))
ImmutableNestedSetModel.Tree{E}:
 1  2  E("A",nothing)
 3  8  E("ELECTRONICS",nothing)
 4  5  - E("B","ELECTRONICS")
 6  7  - E("TELEVISIONS","ELECTRONICS")

```
"""
Base.convert{T}(::Type{Tree}, items::StructItems{T}) = prepare(append!(Tree(T), items))
Base.convert{T}(::Type{KeyedItems}, v::Vector{T}) = KeyedItems(v, 1, 2)

"""
  convert(Tree, items::Table{K, T})::Tree{T}

Convert default elements to Tree.

# Examples

```jldoctest
julia> convert(Tree, [
         ("ELECTRONICS", nothing),
         ("TELEVISIONS", "ELECTRONICS"),
         ("A", nothing),
         ("B", "ELECTRONICS"),
       ])
ImmutableNestedSetModel.Tree{Tuple{String,Any}}:
 1  2  ("A",nothing)
 3  8  ("ELECTRONICS",nothing)
 4  5  - ("B","ELECTRONICS")
 6  7  - ("TELEVISIONS","ELECTRONICS")

```
"""
Base.convert{T<:Union{Tuple, Vector, Associative}}(::Type{Tree}, v::Vector{T}) = prepare(append!(Tree(T), convert(KeyedItems, v)))

iter(t::Tree) = NodeIterator(t.root, true)

Base.push!{T}(t::Tree{T}, n::Node{T}) = push!(t.root, n)

function Base.append!{K, T}(t::Tree{T}, table::Table{K, T})
  nodes = Dict{Any, Node{T}}()

  for (id, item) = table.data
    nodes[id] = newnode(t, item)
  end

  for n = values(nodes)
    parentid = table.getparent(n.data)

    if parentid == nothing
      push!(t, n)
    else
      push!(nodes[parentid], n)
    end
  end
  t
end

function Base.append!{T}(t::Tree{T}, lines::StructItems{T})
  nodes = Dict{Any, nodetype(t)}()

  for item in lines.items
    nodes[getfield(item, lines.idfield)] = newnode(t, item)
  end

  for n in values(nodes)
    parentid = getfield(n.data, lines.parentfield)

    if parentid == nothing
      push!(t, n)
    else
      push!(nodes[parentid], n)
    end
  end
  t
end

function Base.append!{T}(t::Tree{T}, lines::KeyedItems)
  nodes = Dict{Any, nodetype(t)}()

  for item in lines.items
    nodes[item[lines.idkey]] = newnode(t, item)
  end

  for n in values(nodes)
    parentid = n.data[lines.parentkey]

    if parentid == nothing
      push!(t, n)
    else
      push!(nodes[parentid], n)
    end
  end
  t
end

function prepare(t::Tree)
  prepare(t.root, 0)
  t
end

tos(tree::Tree) = show(tree)

function Base.show{T}(io::IO, tree::Tree{T})
  write(io, repr(typeof(tree)), ":\n")
  for node = iter(tree)
    c = parentscount(node)
    write(io, @sprintf "%2d %2d %s %s\n" node.lft node.rgt (c == 0 ? "" : " " * repeat("-", c)) node.data)
  end
end

tov(tree::Tree) = String[tos(node) for node = iter(tree)]
