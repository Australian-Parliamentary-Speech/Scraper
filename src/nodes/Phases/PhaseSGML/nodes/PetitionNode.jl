export PetitionNode

abstract type PetitionNode{P} <: AbstractNode{P} end


function get_xpaths(::Type{PetitionNode{PhaseSGML}})
    return ["petition","petition.grp"]
end
