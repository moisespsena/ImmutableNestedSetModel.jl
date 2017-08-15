include(joinpath(dirname(@__FILE__), "Node0" * (VERSION < v"0.6-" ? "5" : "6") * ".jl"))

Node{T, D}(::Type{T}, ::Type{D}, data::T, lft::Integer, rgt::Integer) =
  Node{T, D}(data, lft, rgt, OrderedDict{Ptr, Node{D, D}}(), nothing, pointer_from_objref(data))
Node{T, D}(::Type{T}, ::Type{D}, data::T) = Node(T, D, data, -1, -1)
Node{D}(data::D, lft::Integer, rgt::Integer) = Node(D, data, lft, rgt)
Node{T}(::Type{T}, data::Union{Void,T}) = Node(Union{Void,T}, Union{Void,T}, data)
Node{T}(::Type{T}) = Node(T, nothing)
Node{D}(data::D) = Node(D, data, -1, -1)
Node() = Node(Any)

AnyNode(lft::Integer, rgt::Integer, data::Any=nothing) = Node(Any, Any, data, lft, rgt)
AnyNode(data::Any=nothing) = Node(Any, Any, data)

function tos(n::Node)
  c = parentscount(n)
  @sprintf "%2d %2d %s %s" n.lft n.rgt (c == 0 ? "" : " " * repeat("-", c)) n.data
end

Base.iteratorsize{T}(::Type{NodeIterator{T}}) = Base.SizeUnknown()

Base.showerror(io::IO, e::NodeDuplicationException) = print(io, "Node ", e.child, " duplicated on ", e.parent)
Base.showerror(io::IO, e::NodeIsRootException) = print(io, "Node ", e.node, " is root node.")

function parents(node::Node)::Vector{Node}
  if node.parent == nothing
    throw(NodeIsRootException(node))
  end
  r = Node[]
  node = node.parent
  while node.parent != nothing
    push!(r, node)
    node = node.parent
  end
  r
end

function parentscount(node::Node)
  if node.parent == nothing
    throw(NodeIsRootException(node))
  end
  i = 0
  node = node.parent
  while node.parent != nothing
    i += 1
    node = node.parent
  end
  i
end

Base.contains(parent::Node, child::Node) = haskey(parent.children, child.key)

function root(node::Node)
  while node.parent != nothing
    node = node.parent
  end
  node
end

function Base.push!(parent::Node, child::Node)
  if contains(parent, child)
    throw(NodeDuplicationException(parent, child))
  end

  child.parent = parent
  parent.children[child.key] = child
  child
end

function Base.append!(result::Vector, node::Node)
  push!(result, node)
  for c in values(node.children)
    append!(result, c)
  end
  result
end

function _foreach(f::Function, n::Node)
  f(n)
  for c in values(n.children)
    _foreach(f, c)
  end
end

Base.foreach(f::Function, n::Node) = _foreach(f, n)

function iternode(f::Function, node::Node, skipself::Bool=false)
  if skipself
    for c in values(node.children)
      _foreach(f, c)
    end
  else
    _foreach(f, node)
  end
end


iter(n::Node) = NodeIterator(n)

function Base.collect{T, D}(node::Node{T, D})
  it = NodeIterator(node)
  append!(it.eltype[], it)
end

function prepare(node::Node, lft::Int64)
  node.lft = lft

  if isempty(node.children)
    node.rgt = node.lft + 1
  else
    for c in values(node.children)
      lft = prepare(c, lft + 1)
    end

    node.rgt = lft + 1
  end

  node.rgt
end
