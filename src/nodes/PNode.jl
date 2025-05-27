export PNode
#export process_node


abstract type PNode{P} <: AbstractNode{P} end

function find_item(node::Node{<:PNode})
    parent = parentnode(node.node)
    if nodename(parent) == "item"
        label = findfirst_in_subsoup(parent.path,"/@label",node.soup)
        if isnothing(label)
            return nothing
        else
            return label.content
        end
    end
    return nothing
end


function construct_row(node::Node{<:PNode},node_tree)
    phase = get_phasetype(node)
    debateinfo =  find_section_title(node_tree,node.soup,DebateNode{phase})
    subdebateinfo =  find_section_title(node_tree,node.soup,SubdebateNode{phase})

    label = find_item(node)
    if !isnothing(label)
        content = label*node.node.content
    else
        content = node.node.content
    end

    node.headers_dict["content"] = content
    node.headers_dict["subdebateinfo"] = subdebateinfo
    node.headers_dict["debateinfo"] = debateinfo
    node.headers_dict["path"] = node.node.path
    row = collect(values(node.headers_dict))
    row_ = []
    for r in row
        if typeof(r) <: Int
            push!(row_,r)
        else
            push!(row_,clean_text(r))
        end
    end
    return row_
end


"""
process_node(node::Node{<:PNode},node_tree)

If no particular phase is specified, this default version of process node is run. 
"""
function process_node(node::Node{<:PNode},node_tree)
    nodetype = typeof(node).parameters[1]
    allowed_names = get_xpaths(nodetype)
    parent_node = node_tree[end]
    edge_case = nothing
    if is_first_node_type(node,parent_node,allowed_names,node_tree)
        if !(is_free_node(node,parent_node))
            get_talker_from_parent(node,parent_node)
            if node.headers_dict["name"] == "N/A"
                edge_case = "no_talker_block_from_parent"
                name = findfirst_in_subsoup(parent_node.node.path,"//name",node.soup)
                if !isnothing(name)
                    edge_case = "any_name_from_parent"
                    node.headers_dict["name"] = name.content
                end
            else
                edge_case = "exist_talker_block_in_parent"
            end
        else
            node.headers_dict["name"] = "FREE NODE"
        end
    else
        edge_case = find_talker_in_p(node)
    end 
    define_flags(node,parent_node,node_tree)
    write_test_xml(node, parent_node, edge_case)
    return construct_row(node,node_tree)
end

"""
is_first_node_type(node::Node{<:PNode},parent_node,allowed_names,node_tree)

This default function detects if the p_node detected is the first p_node under a parent node. The reason for this is that if the p_node is not the first node, there are alternative checks to see if the talker has changed since the first one.
"""
function is_first_node_type(node::Node{<:PNode},parent_node,allowed_names,node_tree)
    if node.index == 1
        for name in allowed_names
            first_p = findfirst_in_subsoup(parent_node.node.path,"//$name",parent_node.soup)
            if !isnothing(first_p)
                is_type = (first_p.path == node.node.path)
                return is_type
            end
        end
        return false
    else
        return false
    end
end


"""
find_talker_in_p(p_node)

If the p_node is not the first p_node, we check if there is a talker inside the p_node.
"""
function find_talker_in_p(p_node::Node{<:PNode})
    p_talker_soup = findfirst_in_subsoup(p_node.node.path,"//a",p_node.soup)
    if isnothing(p_talker_soup)
        p_with_a_as_parent(p_node)
        if p_node.headers_dict["name"] != "N/A" || p_node.headers_dict["name.id"] != "N/A"
            edge_case = "p_with_a_as_parent"
        else
            edge_case = "found_nothing"
        end
        return edge_case
    else
        p_talker  = findfirst_in_subsoup(p_talker_soup.path,"/@type",p_node.soup)
        p_talker_id = findfirst_in_subsoup(p_talker_soup.path,"/@href",p_node.soup)
        p_talker = isnothing(p_talker) ? "N/A" : p_talker.content
        p_talker_id = isnothing(p_talker_id) ? "N/A" : p_talker_id.content
        edge_case = "found_a_in_p_block"
        p_node.headers_dict["name"] = clean_text(p_talker)
        p_node.headers_dict["name.id"] = clean_text(p_talker_id)
        return edge_case
    end
end

"""
p_with_a_as_parent(p_node)

If no talker is found for the first node, we look for a "a" as parentnode.
"""
function p_with_a_as_parent(p_node)
    soup = p_node.soup
    function parent_path_check(parent_path)
        paths = split(parent_path,"/")
        path_end = paths[end]
        return path_end == 'a' || path_end == "a" || occursin(r"^a\[\d+\]$", path_end)
    end
    parent_path = p_node.node.parentnode.path
    if parent_path_check(parent_path)
        p_talker  = findfirst_in_subsoup(parent_path,"/@type",soup)
        p_talker_id = findfirst_in_subsoup(parent_path,"/@href",soup)
        p_talker = isnothing(p_talker) ? "N/A" : p_talker.content
        p_talker_id = isnothing(p_talker_id) ? "N/A" : p_talker_id.content
        p_node.headers_dict["name"] = clean_text(p_talker)
        p_node.headers_dict["name.id"] = clean_text(p_talker_id)
    end
end
#args is a list, kwargs is a dictionary

"""
get_xpaths(::Type{<:PNode})

Find what the p_node is called in xml for default
"""
function get_xpaths(::Type{<:PNode})
   return ["p"]
end

"""
get_sections(::Type{<:PNode})

In which sections are the p_node wanted as default.
"""
function get_sections(::Type{<:PNode})
    return [Node{<:SpeechNode},Node{<:QuestionNode},Node{<:AnswerNode},Node{<:BusinessNode}]
end

"""
is_nodetype(node, node_tree, nodetype::Type{<:PNode},phase::Type{<:AbstractPhase},soup, args...; kwargs...) 

This function detects whether the given xml node is PNode. This function takes the phase into account aswell.
"""
function is_nodetype(node, node_tree, nodetype::Type{<:PNode},phase::Type{<:AbstractPhase},soup, args...; kwargs...) 
    nodetype = nodetype{phase}
    allowed_names = get_xpaths(nodetype)
    name = nodename(node)
    if name in allowed_names
        section_types = get_sections(nodetype)
        parent_node = node_tree[end]
        is_parent = any(section_node -> (typeof(parent_node) <: section_node), section_types)
        return is_parent
    else
        return false
    end
end

"""
parse_node(node::Node{<:PNode},node_tree,io)

The default function to take a p_node and write to the csv
"""
function parse_node(node::Node{<:PNode},node_tree,io)
    row = process_node(node,node_tree)
    write_row_to_io(io,row)
end


