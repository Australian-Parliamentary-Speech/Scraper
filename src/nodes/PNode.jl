export PNode
#export process_node

abstract type PNode <: AbstractNode end

function process_node(node::Node{PNode},node_tree,year,soup)
    phase = year_to_phase(year)
    if phase == :phase1
#        include("/home/eve/Development/ParlinfoSpeechScraper/src/nodes/PNode_phase1.jl")
        allowed_names = get_xpaths(year,PNode)
        row = process_node_phase(node,node_tree,soup;names = allowed_names)
        number = minimum([length(row[end]),200])
        @info vcat(row[1:end-1],row[end][1:number])
        return row
    else
        @error "Node not processed"
    end
end

#args is a list, kwargs is a dictionary
function is_nodetype(node, node_tree, ::Type{PNode}, args...; kwargs...)
    year = kwargs[:year]

    allowed_names = get_xpaths(year,PNode)
    name = nodename(node)
    if name in allowed_names
        section_names = get_sections_for_p(year,PNode)
        parent_node = reverse_find_first_node_not_name(node_tree,allowed_names)
        return nodename(parent_node.node) ∈ section_names
    else
        return false
    end
end

#is_nodetype(node, node_tree, NodeType, a, b, c; d=1, e=3)

function get_xpaths(year,::Type{PNode})
   phase_to_dict = Dict(
                        :phase1 => ["p"]) 
    return  phase_to_dict[year_to_phase(year)]
end

function get_sections_for_p(year,::Type{PNode})
   phase_to_dict = Dict(
                        :phase1 => ["speech","answer","question","business.start"]) 
    return  phase_to_dict[year_to_phase(year)]
end



function parse_node(node::Node{PNode},node_tree,year,soup,io)
    row = process_node(node,node_tree,year,soup)
    write_row_to_io(io,row)
end


