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
    date::Float64
    soup
end

# Get Default Nodes
const node_path = joinpath(@__DIR__, "nodes")
for path in readdir(node_path, join=true)
    if isfile(path)
        include(path)
    end
end

# Included phases can add to this dictionary
date_to_phase = Dict()

# Included phases can add to this dictionary
range_to_phase = Dict()

# Get Phase Overwrites
const phase_path = joinpath(node_path, "Phases")
for dir in readdir(phase_path, join=true)
    for path in readdir(dir, join=true)
        if isfile(path)
            include(path)
        end
    end
end

function detect_phase(date)
    # See if year has specific phase
    phase = get(date_to_phase, date, nothing)
    if ! isnothing(phase)
        return phase
    end

    # See if date in range with phase
    for (date_range,phase) in date_to_phase
        min_date, max_date = date_range
        if min_date <= date <= max_date
            return phase
        end
    end

    # Any other logic you want can go here

    # No specific phase for this date
    return AbstractPhase
end

"""
    get_all_subtypes(type, st=[])

Get every subtype of the provided `type` parameter.

Inputs:
- `type`: ...
"""
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

function detect_node_type(node, node_tree,date,soup,PhaseType)
    for NodeType in all_subtypes
        if is_nodetype(node, node_tree, NodeType, PhaseType,soup)
            return NodeType
        end
    end
end

#all style has direction in it so does not work
#function detect_stage_direction(node::Node)
#    for atnode in attributes(node.node)
#        if nodename(atnode) == "style"
#            if occursin("direction",atnode.content)
#                return true
#            end
#        end
#    end
#    return false  
#end
#
function parse_node(node::Node,node_tree,io)
    process_node(node,node_tree)
end

function process_node(node::Node,node_tree)
    nothing
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

function find_section_title(node,node_tree,soup,section_type)
    section_title_path = get_section_title_path(section_type)
    section_node = reverse_find_first_node_name(node_tree,get_xpaths(section_type))
    if isnothing(section_node)
        return "N/A"
    end
    title = findfirst_in_subsoup(section_node.node.path,section_title_path,soup)
    if isnothing(title)
        return "N/A"
    else
        return title.content
    end
end

#Fedchamber - 2 Chamber - 1
function find_chamber(node,node_tree)
    chamber_node = reverse_find_first_node_name(node_tree,vcat(get_xpaths(ChamberNode),get_xpaths(FedChamberNode)))
    if chamber_node isa Node{<:FedChamberNode}
        return 2
    elseif chamber_node isa Node{<:ChamberNode}
        return 1
    else
#        @error "no chamber is found"
        return 0
    end
end

function define_flags(node::Node{<:AbstractNode{<:AbstractPhase}},parent_node,node_tree)
    ParentTypes = [QuestionNode,AnswerNode,InterjectionNode,SpeechNode]
    flags = map(node_type -> parent_node isa Node{<:node_type} ? 1 : 0, ParentTypes)
    chamber = find_chamber(node,node_tree)
    push!(flags,chamber)
    return flags
end



function construct_row(node,node_tree,flags,talker_contents,content)
    debateinfo =  find_section_title(node,node_tree,node.soup,DebateNode)
    subdebateinfo =  find_section_title(node,node_tree,node.soup,SubdebateNode)
    row = [flags...,talker_contents...,clean_text(content),subdebateinfo,debateinfo,node.node.path]
#    @assert length(row) == 12
    return row
end
 

end


