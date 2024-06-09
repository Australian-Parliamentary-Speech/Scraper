export SubdebateNode

abstract type SubdebateNode{P} <: AbstractNode{P} end


function get_xpaths(::Type{<:SubdebateNode})
    return ["subdebate.text"]
end

