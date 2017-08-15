type Tree{T}
  root::Node{Void, T}
end

type KeyedItems
 items::Vector
 idkey
 parentkey
end

type StructItems{T}
 items::Vector{T}
 idfield::Symbol
 parentfield::Symbol
end

type Table{K, V}
  data::Associative{K, V}
  getparent::Function
end
