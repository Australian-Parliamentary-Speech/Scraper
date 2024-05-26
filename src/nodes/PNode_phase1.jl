function process_node_phase(node::Node{PNode},node_tree,args...;kwargs...)
    allowed_names = get_xpaths(node.year,PNode)
    parent_node = reverse_find_first_node_not_name(node_tree,allowed_names)
    if is_first_node_type(node)
        parent_node_ = node_tree[end]
        @assert parent_node_ == parent_node
        talker_contents = get_talker_from_parent(parent_node)
    else
        talker_contents = find_talker_in_p(node)
    end 
    flags = define_flags(parent_node)
    return construct_row(flags,talker_contents,node.node.content)
end


function find_talker_in_p(p_node)
    p_talker = findfirst_in_subsoup(p_node.node.path,p_node.soup,"//a")
    if !isnothing(p_talker)
        @show p_talker
    end
    if isnothing(p_talker)
        return [p_with_a_as_parent(p_node),"N/A","N/A","N/A"]
    else
        return [p_talker.content,"N/A","N/A","N/A"]
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
        p_talkers  = findfirst_in_subsoup(p_node.node.parentnode.path,soup,"/@type")
        if p_talkers != nothing
            return  p_talkers.content
        else
            return "N/A"
        end
    else
        return "N/A"
    end
end
