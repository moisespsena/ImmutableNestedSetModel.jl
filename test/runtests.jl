include(joinpath(dirname(@__FILE__), "..", "src", "ImmutableNestedSetModel.jl"))
using ImmutableNestedSetModel
#using Base.Test

# write your own tests here
#@test 1 == 2

#=
table = ATree()

function pl()
  for node = table
    println(repeat("-", parentscount(node)) * repr(node))
  end
  println("")
end

pl()

append!(table, Node("--"))
append!(table, Node("-- 2"))
pl()

=#
#=
r = [
  Node("ELECTRONICS"),
  Node("TELEVISIONS"),
  Node("TUBE"),
  Node("LCD"),
  Node("PLASMA"),
  Node("PORTABLE ELECTRONICS"),
  Node("MP3 PLAYERS"),
  Node("FLASH"),
  Node("CD PLAYERS"),
  Node("2 WAY RADIOS"),
]

push!(r[1], r[2])
push!(r[2], r[3])
push!(r[2], r[4])
push!(r[2], r[5])
push!(r[1], r[6])
push!(r[6], r[7])
push!(r[7], r[8])
push!(r[6], r[9])
push!(r[6], r[10])

push!(tree.root, r[1])
prepare(tree)
=#
t = Tree()
