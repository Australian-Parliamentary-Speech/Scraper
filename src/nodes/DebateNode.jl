export DebateNode

abstract type DebateNode{P} <: AbstractNode{P} end


function get_xpaths(::Type{<:DebateNode})
    return ["debate"]
end


