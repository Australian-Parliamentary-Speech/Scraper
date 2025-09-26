function get_xpaths(::Type{InterTalkNode{Phase2011}})
    return ["talk.start"]
end

function process_node(node::Node{InterTalkNode{Phase2011}},node_tree)
    nothing
end

function parse_node(node::Node{InterTalkNode{Phase2011}},node_tree,io)
    nothing
end


function is_nodetype(node, node_tree, nodetype::Type{<:InterTalkNode}, phase::Type{Phase2011}, soup, args...; kwargs...)
    NP = nodetype{phase}
    allowed_names = get_xpaths(NP)
    name = nodename(node)
    return name in allowed_names
end

