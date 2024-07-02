export FedChamberNode

abstract type FedChamberNode{P} <: AbstractNode{P} end


function get_xpaths(::Type{<:FedChamberNode})
    return ["fedchamb.xscript","maincomm.xscript"]
end
