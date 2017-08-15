mutable struct Node{T, D}
  data::T
  lft::Integer
  rgt::Integer
  children::OrderedDict{Ptr, Node{D, D}}
  parent::Union{Void,Node}
  key::Ptr
end

struct NodeDuplicationException <: Exception
  parent::Node
  child::Node
end

struct NodeIsRootException <: Exception
  node::Node
end

mutable struct NodeIterator{T}
  node::Node
  eltype::Type{T}
  chan::Channel
end

function NodeIterator{T, D}(node::Node{T, D}, skipself=false)
  chan = Channel(0)
  @schedule begin
    iternode(i->put!(chan, i), node, skipself)
    close(chan)
  end

  NodeIterator(node,
    ((skipself || T == D) ? Node{D, D} : Union{Node{T, D}, Node{D, D}}),
    chan
  )
end

Base.start(it::NodeIterator) = nothing
Base.done(it::NodeIterator, state) = !isopen(it.chan)
Base.next(it::NodeIterator, state) = take!(it.chan), nothing
