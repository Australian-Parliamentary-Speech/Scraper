export AnswerNode

abstract type AnswerNode{P} <: AbstractNode{P} end


"""
    is_nodetype(node, node_tree, ::Type{<:AnswerNode}, phase, soup, args...; kwargs...)

A `<continue>` tag counts as an `AnswerNode` if its parent's tag does - it
inherits type from context rather than being named `answer` itself.
"""
function is_nodetype(node, node_tree,nodetype::Type{<:AnswerNode},phase::Type{<:AbstractPhase},soup, args...; kwargs...)
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


function get_xpaths(::Type{<:AnswerNode})
   return ["answer"]
end

