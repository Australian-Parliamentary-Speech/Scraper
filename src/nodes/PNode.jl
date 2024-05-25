export PNode
#export process_node

abstract type PNode <: AbstractNode end

function process_node(node::Node{PNode},node_tree)
    phase = year_to_phase(node.year)
    if phase == :phase1
        row = process_node_phase(node,node_tree)
        return row
    else
        @error "Node not processed"
    end
end

#args is a list, kwargs is a dictionary

function get_xpaths(year,::Type{PNode})
   phase_to_dict = Dict(
                        :phase1 => ["p"]) 
    return  phase_to_dict[year_to_phase(year)]
end

function get_sections(year,::Type{PNode})
   phase_to_dict = Dict(
                        :phase1 => ["speech","answer","question","business.start"]) 
    return  phase_to_dict[year_to_phase(year)]
end




