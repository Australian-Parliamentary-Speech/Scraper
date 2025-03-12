export SpeechNode

abstract type SpeechNode{P} <: AbstractNode{P} end



function is_nodetype(node, node_tree,nodetype::Type{<:SpeechNode},phase::Type{<:AbstractPhase},soup, args...; kwargs...)
    nodetype = nodetype{phase}
    allowed_names = get_xpaths(nodetype)
    name = nodename(node)
    if name == "continue"
        parent = node_tree[end]
        parent_name = nodename(parent.node)
        return parent_name in allowed_names
    else
        return name in allowed_names
    end
end

function get_xpaths(::Type{<:SpeechNode})
    return ["speech"]
end


