export QuoteNode_

abstract type QuoteNode_{P} <: AbstractNode{P} end


function get_xpaths(::Type{QuoteNode_{PhaseSGML}})
    return ["quote"]
end


