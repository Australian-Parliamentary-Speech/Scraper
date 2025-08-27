export TableNode
#To avoid getting table contents
abstract type TableNode{P} <: AbstractNode{P} end


function get_xpaths(::Type{<:TableNode})
    return ["table"]
end
