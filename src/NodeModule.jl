module NodeModule
using InteractiveUtils

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
        st = vcat(st, get_all_subtypes(subt, st))
    end
    return st
end

function reverse_find_first_node(node_tree,name)
    reverse_node_tree = reverse(node_tree)
    node = findfirst(n -> nodename(n) == name,reverse_node_tree)
    return node
end

function find_debate_title(node)
    debate_title = "/debateinfo/title"
    debate_node = reverse_find_first_node(node_tree,"debate")
    title = find_in_subsoup(debate_node.path,soup,debate_title,:first).content
    return title
end
 

function is_nodetype(node,node_tree,::Node,args...;kwargs...)
    @info typeof(node)
    return false
end

function detect_node_type(node, node_tree,year)
    for NodeType in get_all_subtypes(Node)
        @info NodeType
        if is_nodetype(node, node_tree, NodeType;year=year)
            return NodeType
        end
    end
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


