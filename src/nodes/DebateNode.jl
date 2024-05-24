export DebateNode

abstract type DebateNode <: AbstractNode end

function process_node(node::Node{DebateNode},node_tree,year,soup)
    phase = year_to_phase(year)
    if phase == :phase1
        nothing
    else
        @error "Node not processed"
    end
end


function is_nodetype(node, node_tree, ::Type{DebateNode}, args...; kwargs...)
    year = kwargs[1]
    allowed_names = get_xpaths(year,DebateNode)
    name = nodename(node)
    return name in allowed_names
end


function get_xpaths(year,::Type{DebateNode})
    phase_to_dict = Dict(
                        :phase1 => ["debate"]) 
    return  phase_to_dict[year_to_phase(year)]
end


