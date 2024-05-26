#using Reexport
#@reexport module 

module NodeModule
using InteractiveUtils
using EzXML
using ..XMLModule
using ..Utils

export detect_node_type
export Node
export GenericNode
export parse_node

abstract type AbstractNode end

abstract type GenericNode <: AbstractNode end

struct Node{N <: AbstractNode}
    node::EzXML.Node
    index::Int64
    year::Int64
    soup
end

const node_path = joinpath(@__DIR__, "nodes")
for path in readdir(node_path, join=true)
    if isfile(path)
        include(path)
    end
end

function get_all_subtypes(type, st=[])
    for subt in subtypes(type)
        push!(st,subt)
        get_all_subtypes(subt, st)
    end
    return st
end

const all_subtypes = get_all_subtypes(AbstractNode)

function reverse_find_first_node_name(node_tree,names)
    reverse_node_tree = reverse(node_tree)
    index = findfirst(n -> nodename(n.node) ∈ names,reverse_node_tree)
    if isnothing(index)
        return nothing
    else
        return reverse_node_tree[index]
    end
end


function reverse_find_first_node_not_name(node_tree,names)
    reverse_node_tree = reverse(node_tree)
    index = findfirst(n -> nodename(n.node) ∉ names,reverse_node_tree)
    if isnothing(index)
        return nothing
    else
        return reverse_node_tree[index]
    end
end

function is_first_node_type(node)
    return node.index == 1
end


function find_debate_title(node,node_tree,soup)
    debate_title = "/debateinfo/title"
    debate_node = reverse_find_first_node_name(node_tree,["debate"])
    if isnothing(debate_node)
        return "N/A"
    end
    title = findfirst_in_subsoup(debate_node.node.path,debate_title,soup)
    if isnothing(title)
        return "N/A"
    else
        return title.content
    end
end
 

function detect_node_type(node, node_tree,year,soup)
    for NodeType in all_subtypes
        if is_nodetype(node, node_tree, NodeType, soup;year=year)
            return NodeType
        end
    end
end

function define_flags(parent_node)
    if isnothing(parent_node)
        return [0,0,0,0,0]
    end
    name = nodename(parent_node.node)
    if name == "question"
        flags = [1,0,0,0,0]
    elseif name == "answer"
        flags = [0,1,0,0,0]
    elseif name == "interjection"
        flags = [0,0,1,0,0]
    elseif name == "speech"
        flags = [0,0,0,1,0]
    else
        flags = [0,0,0,0,0]
    end
    return flags 
end



function year_to_phase(year)
    if 2020 < year < 2024
        return :phase1
    else
        @error "No phase was produced in questionnode"
    end
end

function parse_node(node::Node,node_tree,io)
    process_node(node,node_tree)
end

function parse_node(node::Union{Node{InterTalkNode},Node{PNode}},node_tree,io)
    row = process_node(node,node_tree)
    write_row_to_io(io,row)
end

function process_node(node::Node,node_tree)
    phase = year_to_phase(node.year)
    if phase == :phase1
        nothing
    else
        @error "Node not processed"
    end
end

function is_nodetype(node, node_tree, nodetype::Union{Type{PNode},Type{InterTalkNode}}, args...; kwargs...)
    year = kwargs[:year]
    allowed_names = get_xpaths(year,nodetype)
    name = nodename(node)
    if name in allowed_names
        section_names = get_sections(year,nodetype)
        parent_node = reverse_find_first_node_not_name(node_tree,allowed_names)
        return nodename(parent_node.node) ∈ section_names
    else
        return false
    end
end

function is_nodetype(node, node_tree, nodetype::Type{N}, args...; kwargs...) where {N <: AbstractNode}
    year = kwargs[:year]
    soup = args[1]
    allowed_names = get_xpaths(year,N)
    name = nodename(node)
    return name in allowed_names
end

function construct_row(flags,talker_contents,content)
    return [flags...,talker_contents...,clean_text(content)]
end
 
function get_xpaths(year, ::Type{N}) where {N <: AbstractNode}
    return []
end
#function detect_node_type(node,node_tree)
#    name = nodename(node)
#    node_struct_name = nodename_to_structname(name)
#    parent_node = node_tree[end-1]
#    node_struct_symbol = Symbol("$(uppercasefirst(node_struct_name))Node")
#    node_struct = getfield(NodeModule,node_struct_symbol)
#    return node_struct
#end
#

end


