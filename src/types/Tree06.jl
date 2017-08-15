struct Tree{T}
  root::Node{Void, T}
end

struct KeyedItems
 items::Vector
 idkey
 parentkey
end

struct StructItems{T}
 items::Vector{T}
 idfield::Symbol
 parentfield::Symbol
end

struct Table{K, V}
  data::Associative{K, V}
  getparent::Function
end
