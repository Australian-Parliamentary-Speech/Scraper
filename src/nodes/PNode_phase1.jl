function process_node_phase(node::Node{PNode},node_tree,args...;kwargs...)
    allowed_names = get_xpaths(node.year,PNode)
    parent_node = reverse_find_first_node_not_name(node_tree,allowed_names)
    if is_first_node_type(node_tree,PNode)
        parent_node_ = node_tree[end-1]
        @assert parent_node_ == parent_node
        talker_contents = get_talker_from_parent(parent_node)
    else
        talker_contents = find_talker_in_p(node)
    end 
    flags = define_flags(parent_node)
    row = [flags...,talker_contents...,clean_text(node.node.content)]
    return row
end

function get_talker_from_parent(parent_node)
    soup = parent_node.soup
    parent_node = parent_node.node
    talker_node = findfirst_in_subsoup(parent_node.path,"//talker",soup)
    function find_content(xpath)
        talker_content_node = findfirst_in_subsoup(talker_node.path,xpath,soup)
        #        talker_content_node = findfirst("$(talker_node.path)//$(xpath)",talker_node)
        return talker_content_node.content
    end

    if isnothing(talker_node)
        return ["N/A" for i in 1:4]
    else
        talker_contents = []
        for xpath in ["//name","//name.id","//electorate","//party"]
            talker_content = find_content(xpath)
            push!(talker_contents,talker_content)
        end
        return talker_contents
    end
end


function find_talker_in_p(p_node)
    p_talker = findfirst_in_subsoup(p_node.node.path,p_node.soup,"//a")
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
