export PNode
#export process_node


abstract type PNode{P} <: AbstractNode{P} end

function process_node(node::Node{<:PNode},node_tree)
    nodetype = typeof(node).parameters[1]
    allowed_names = get_xpaths(nodetype)
#    parent_node = reverse_find_first_node_not_name(node_tree,allowed_names)
    parent_node = node_tree[end]
    if is_first_node_type(node,parent_node,allowed_names,node_tree)
        talker_contents = get_talker_from_parent(nodetype,parent_node)
    else
        talker_contents = find_talker_in_p(node)
    end 
    flags = define_flags(node,parent_node,node_tree)
    return construct_row(node,node_tree,flags,talker_contents,node.node.content)
end

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

function find_talker_in_p(p_node)
    p_talker = findfirst_in_subsoup(p_node.node.path,"//a",p_node.soup)
    if isnothing(p_talker)
        return [clean_text(p_with_a_as_parent(p_node)),"N/A","N/A","N/A","N/A","N/A"]
    else
        return [clean_text(p_talker.content),"N/A","N/A","N/A","N/A","N/A"]
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
#args is a list, kwargs is a dictionary

function get_xpaths(::Type{<:PNode})
   return ["p"]
end



function get_sections(::Type{<:PNode})
    return [Node{<:SpeechNode},Node{<:QuestionNode},Node{<:AnswerNode},Node{<:BusinessNode}]
end


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

function parse_node(node::Node{<:PNode},node_tree,io)
    row = process_node(node,node_tree)
    write_row_to_io(io,row)
end



function get_talker_from_parent(::Type{<:PNode},parent_node)
    soup = parent_node.soup
    parent_node = parent_node.node
    talker_node = findfirst_in_subsoup(parent_node.path,"//talker",soup)
    function find_content(xpath)
        talker_content_node = findfirst_in_subsoup(talker_node.path,xpath,soup)
        if isnothing(talker_content_node)
            return "N/A"
        else
            return talker_content_node.content
        end
    end

    talker_xpaths = ["//name","//name.id","//electorate","//party","//role","//page.no"]
    if isnothing(talker_node)
        return ["N/A" for i in 1:length(talker_xpaths)]
    else
        talker_contents = []
        for xpath in talker_xpaths
            talker_content = find_content(xpath)
            push!(talker_contents,talker_content)
        end
        return talker_contents
    end
end

