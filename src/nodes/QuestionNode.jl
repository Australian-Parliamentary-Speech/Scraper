export QuestionNode

abstract type QuestionNode{P} <: AbstractNode{P} end


function is_nodetype(node, node_tree,nodetype::Type{<:QuestionNode},phase::Type{<:AbstractPhase},soup, args...; kwargs...)
    nodetype = nodetype{phase}
    allowed_names = get_xpaths(nodetype)
    name = nodename(node)
    return name in allowed_names
end


function get_xpaths(::Type{<:QuestionNode})
   return ["question"]
end


