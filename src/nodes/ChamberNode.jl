export ChamberNode

abstract type ChamberNode{P} <: AbstractNode{P} end


function get_xpaths(::Type{<:ChamberNode})
    return ["chamber.xscript"]
end

