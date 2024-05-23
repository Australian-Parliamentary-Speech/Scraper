#using Reexport
#@reexport module 

module NodeModule
using InteractiveUtils
using EzXML
using ..XMLModule

export detect_node_type
export Node

abstract type Node end

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

function reverse_find_first_node(node_tree,name)
    reverse_node_tree = reverse(node_tree)
    index = findfirst(n -> nodename(n[1]) == name,reverse_node_tree)
    if isnothing(index)
        return nothing
    else
        return reverse_node_tree[index]
    end
end

function reverse_find_first_node_not_name(node_tree,names)
    reverse_node_tree = reverse(node_tree)
    index = findfirst(n -> nodename(n[1]) ∉ names,reverse_node_tree)
    if isnothing(index)
        return nothing
    else
        return reverse_node_tree[index]
    end
end

function is_first_node_type(node_tree,NodeType)
    previous_node_type = node_tree[end][2]
    return !(previous_node_type == NodeType)
end


function find_debate_title(node,node_tree,soup)
    debate_title = "/debateinfo/title"
    debate_node = reverse_find_first_node(node_tree,"debate")
    if isnothing(debate_node)
        return "N/A"
    end
    title = findfirst_in_subsoup(debate_node.path,debate_title,soup)
    if isnothing(title)
        return "N/A"
    else
        return title.content
    end
end
 

function is_nodetype(node,node_tree,::Node,args...;kwargs...)
    return false
end

function detect_node_type(node, node_tree,year,soup)
    for NodeType in get_all_subtypes(Node)
        if is_nodetype(node, node_tree, NodeType, soup;year=year)
            return NodeType
        end
    end
end

function define_flags(parent_node)
    name = nodename(parent_node)
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


