export InterTalkNode

abstract type InterTalkNode <: AbstractNode end


function get_xpaths(year,::Type{InterTalkNode})
   phase_to_dict = Dict(
                        :phase1 => ["talk.start"]) 
    return  phase_to_dict[year_to_phase(year)]
end


function process_node(node::Node{InterTalkNode},node_tree)
    phase = year_to_phase(node.year)
    if phase == :phase1
        row = process_node_phase(node,node_tree)
        return row
    else
        @error "Node not processed"
    end
end


function get_sections(year,::Type{InterTalkNode})
   phase_to_dict = Dict(
                        :phase1 => ["interjection","continue"]) 
    return  phase_to_dict[year_to_phase(year)]
end


