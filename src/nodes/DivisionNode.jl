export DivisionNode

abstract type DivisionNode{P} <: AbstractNode{P} end


function get_xpaths(::Type{<:DivisionNode})
    return ["division"]
end

