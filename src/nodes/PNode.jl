abstract type PNode <: Node end

#args is a list, kwargs is a dictionary
function is_nodetype(node, node_tree, ::Pnode, args...; kwargs...)
    allowed_names = args[1]
    name = nodename(node)
    if name in allowed_names
        return true
    end
end

#is_nodetype(node, node_tree, NodeType, a, b, c; d=1, e=3)


