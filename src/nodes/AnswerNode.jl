export AnswerNode

abstract type AnswerNode{P} <: AbstractNode{P} end


function is_nodetype(node, node_tree,nodetype::Type{<:AnswerNode},phase::Type{<:AbstractPhase},soup, args...; kwargs...)
    nodetype = nodetype{phase}
    allowed_names = get_xpaths(nodetype)
    name = nodename(node)
    return name in allowed_names
end


function get_xpaths(::Type{<:AnswerNode})
   return ["answer"]
end

