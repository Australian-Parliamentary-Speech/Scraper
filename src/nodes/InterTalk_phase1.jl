function process_node_phase(node::Node{InterTalkNode},node_tree)
    text_node = findfirst_in_subsoup(node.node.path,node.soup,"//talk.text")
    if isnothing(text_node)
        content = filter_node_content_by_paths(node.node,["$(node.node.path)/talker"])
    else
        content = text_node.content
    end

    allowed_names = get_xpaths(node.year,InterTalkNode)
    parent_node = reverse_find_first_node_not_name(node_tree,allowed_names) 
    if true
        parent_node_ = node.node.parentnode
        @assert parent_node_ == parent_node.node
    end

    talker_contents = get_talker_from_parent(parent_node)
    flags = define_flags(parent_node)
    return construct_row(flags,talker_contents,content)
end
