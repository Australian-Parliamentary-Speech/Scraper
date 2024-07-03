export TableNode

abstract type TableNode{P} <: AbstractNode{P} end

function get_xpaths(::Type{<:DivisionNode})
    return ["table"]
end
