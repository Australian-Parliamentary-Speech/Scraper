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
export detect_phase
export GenericPhase
export AbstractPhase

abstract type AbstractPhase end

abstract type GenericPhase <: AbstractPhase end

abstract type AbstractNode{P <: AbstractPhase} end

abstract type GenericNode{P} <: AbstractNode{P} end

struct Node{N <: AbstractNode}
    node::EzXML.Node
    index::Int64
    year::Int64
    soup
end

# Get Default Nodes
const node_path = joinpath(@__DIR__, "nodes")
for path in readdir(node_path, join=true)
    if isfile(path)
        include(path)
    end
end

# Get Phase Overwrites
const phase_path = joinpath(node_path, "Phases")
for dir in readdir(phase_path, join=true)
    for path in readdir(dir, join=true)
        include(path)
    end
end

function detect_phase(year)
    return AbstractPhase
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

function detect_node_type(node, node_tree,year,soup,PhaseType)
    for NodeType in all_subtypes
        if is_nodetype(node, node_tree, NodeType, PhaseType,soup)
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

function parse_node(node::Node,node_tree,io)
    process_node(node,node_tree)
end


function parse_node(node::Union{Node{<:InterTalkNode},Node{<:PNode}},node_tree,io)
    row = process_node(node,node_tree)
    write_row_to_io(io,row)
end

function is_nodetype(node, node_tree, nodetype::Type{<:AbstractNode}, phase::Type{<:AbstractPhase}, soup, args...; kwargs...)
    NP = nodetype{phase}
    allowed_names = get_xpaths(NP)
    name = nodename(node)
    return name in allowed_names
end

function get_xpaths(::Type{<:N}) where {N <: AbstractNode}
    return []
end


function process_node(node::Node,node_tree)
    nothing
end

function construct_row(flags,talker_contents,content)
    return [flags...,talker_contents...,clean_text(content)]
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


end


