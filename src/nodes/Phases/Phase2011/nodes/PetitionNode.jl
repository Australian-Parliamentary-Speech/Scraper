export PetitionNode

abstract type PetitionNode{P} <: AbstractNode{P} end


function get_xpaths(::Type{PetitionNode{Phase2011}})
    return ["petition"]
end
