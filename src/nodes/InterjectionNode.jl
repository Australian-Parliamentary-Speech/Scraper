export InterjectionNode

abstract type InterjectionNode{P} <: AbstractNode{P} end


function get_xpaths(::Type{<:InterjectionNode})
    return ["interjection"]
end

