type Node{T, D}
  data::T
  lft::Integer
  rgt::Integer
  children::OrderedDict{Ptr, Node{D, D}}
  parent::Union{Void,Node}
  key::Ptr
end
type NodeDuplicationException <: Exception
  parent::Node
  child::Node
end

type NodeIsRootException <: Exception
  node::Node
end

type NodeIterator{T}
  node::Node
  eltype::Type{T}
  task::Task
end

NodeIterator{T, D}(node::Node{T, D}, skipself=false) =
  NodeIterator(node,
    ((skipself || T == D) ? Node{D, D} : Union{Node{T, D}, Node{D, D}}),
    @task iternode(produce, node, skipself)
  )

Base.start(it::NodeIterator) = start(it.task)
Base.done(it::NodeIterator, state) = done(it.task, state)
Base.next(it::NodeIterator, state) = next(it.task, state)
