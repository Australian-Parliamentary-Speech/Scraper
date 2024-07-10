export InterTalkNode

abstract type InterTalkNode{P} <: AbstractNode{P} end

"""
get_xpaths(::Type{<:InterTalkNode})

The default setting for what nodenames are allowed for intertalknode.
"""
function get_xpaths(::Type{<:InterTalkNode})
    return ["talk.start"]
end

"""
process_node(node::Node{<:InterTalkNode},node_tree)

The default setting for processing intertalknodes.
"""
function process_node(node::Node{<:InterTalkNode},node_tree)
    text_node = findfirst_in_subsoup(node.node.path,node.soup,"//talk.text")
    if isnothing(text_node)
        content = filter_node_content_by_paths(node.node,["$(node.node.path)/talker"])
    else
        content = text_node.content
    end

    allowed_names = get_xpaths(InterTalkNode)
    parent_node = reverse_find_first_node_not_name(node_tree,allowed_names) 
    if true
        parent_node_ = node.node.parentnode
        @assert parent_node_ == parent_node.node
    end

    talker_contents = get_talker_from_parent(InterTalkNode,parent_node)
    flags = define_flags(node,parent_node,node_tree)
    return construct_row(node,node_tree,flags,talker_contents,content)
end

"""
get_sections(::Type{<:InterTalkNode})

The default setting for the sections where intertalknodes are processed
"""
function get_sections(::Type{<:InterTalkNode})
    return [Node{<:InterjectionNode}]
end


"""
is_nodetype(node, node_tree, nodetype::Type{<:InterTalkNode},phase::Type{<:AbstractPhase},soup, args...; kwargs...) 

This function checks if the given xml node is of nodetype InterTalkNode
"""
function is_nodetype(node, node_tree, nodetype::Type{<:InterTalkNode},phase::Type{<:AbstractPhase},soup, args...; kwargs...) 
    nodetype = nodetype{phase}
    allowed_names = get_xpaths(nodetype)
    name = nodename(node)
    if name in allowed_names
        section_types = get_sections(nodetype)
        parent_node = node_tree[end]
        return any(section_node -> (typeof(parent_node) <: section_node), section_types)
    else
        return false
    end
end

function parse_node(node::Node{<:InterTalkNode},node_tree,io)
    row = process_node(node,node_tree)
    write_row_to_io(io,row)
end

"""
get_talker_from_parent(::Type{InterTalkNode},parent_node)

Get the talker information from the parentnode.
"""
function get_talker_from_parent(::Type{InterTalkNode},parent_node)
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


