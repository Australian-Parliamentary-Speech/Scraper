export AdjournmentNode

abstract type AdjournmentNode{P} <: AbstractNode{P} end


function get_xpaths(::Type{AdjournmentNode{Phase2011}})
    return ["adjournment"]
end

