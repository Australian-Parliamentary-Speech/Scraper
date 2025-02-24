export SpeechNode

abstract type SpeechNode{P} <: AbstractNode{P} end



function is_nodetype(node, node_tree,nodetype::Type{<:SpeechNode},phase::Type{<:AbstractPhase},soup, args...; kwargs...)
    nodetype = nodetype{phase}
    allowed_names = get_xpaths(nodetype)
    name = nodename(node)
    return name in allowed_names
end

function get_xpaths(::Type{<:SpeechNode})
    return ["speech","continue"]
end


