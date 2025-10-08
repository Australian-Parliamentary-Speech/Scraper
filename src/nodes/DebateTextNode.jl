export DebateTextNode

abstract type DebateTextNode{P} <: AbstractNode{P} end


function is_nodetype(node, node_tree,nodetype::Type{<:DebateTextNode},phase::Type{<:AbstractPhase},soup, args...; kwargs...)
    nodetype = nodetype{phase}
    allowed_names = get_xpaths(nodetype)
    name = nodename(node)
    return name in allowed_names
end


function get_xpaths(::Type{<:DebateTextNode})
   return ["debate.text","subdebate.text"]
end

