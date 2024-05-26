function process_node_phase(node::Node{PNode},node_tree,args...;kwargs...)
    allowed_names = get_xpaths(node.year,PNode)
    parent_node = reverse_find_first_node_not_name(node_tree,allowed_names)
    if is_first_node_type(node,parent_node,allowed_names)
        parent_node_ = node_tree[end]
        @assert parent_node_ == parent_node
        talker_contents = get_talker_from_parent(parent_node)
    else
        talker_contents = find_talker_in_p(node)
    end 
    flags = define_flags(parent_node)
    return construct_row(flags,talker_contents,node.node.content)
end

function is_first_node_type(node::Node{PNode},parent_node,allowed_names)
    if node.index == 1
        for name in allowed_names
            first_p = findfirst_in_subsoup(parent_node.node.path,"//$name",parent_node.soup)
            if !isnothing(first_p)
                return first_p.path == node.node.path
            end
        end
        return false
    else
        return false
    end
end


function find_talker_in_p(p_node)
    p_talker = findfirst_in_subsoup(p_node.node.path,"//a",p_node.soup)
    if isnothing(p_talker)
        return [clean_text(p_with_a_as_parent(p_node)),"N/A","N/A","N/A"]
    else
        return [clean_text(p_talker.content),"N/A","N/A","N/A"]
    end
end

function p_with_a_as_parent(p_node)
    soup = p_node.soup
    function parent_path_check(parent_path)
        paths = split(parent_path,"/")
        path_end = paths[end]
        if path_end == 'a' || path_end == "a" || occursin(r"^a\[\d+\]$", path_end)
            return true
        else
            return false
        end
    end
    if parent_path_check(p_node.node.parentnode.path)
        p_talkers  = findfirst_in_subsoup(p_node.node.parentnode.path,"/@type",soup)
        if p_talkers != nothing
            return  p_talkers.content
        else
            return "N/A"
        end
    else
        return "N/A"
    end
end
