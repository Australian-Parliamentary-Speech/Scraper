export BusinessNode

abstract type BusinessNode <: AbstractNode end


function process_node(node::Node{BusinessNode},node_tree,year,soup)
    phase = year_to_phase(year,BusinessNode)
    if phase == :phase1
        nothing
    else
        @error "Node not processed"
    end
end

function is_nodetype(node, node_tree,::Type{BusinessNode}, args...; kwargs...)
    year = kwargs[:year]
    soup = args[1]
    allowed_names = get_xpaths(year,BusinessNode)
    name = nodename(node)
    return name in allowed_names
end


function get_xpaths(year,::Type{BusinessNode})
   phase_to_dict = Dict(
                        :phase1 => ["business.start"]) 
    return  phase_to_dict[year_to_phase(year,BusinessNode)]
end

function year_to_phase(year,::Type{BusinessNode})
    if 2020 < year < 2024
        return :phase1
    else
        @error "No phase was produced in questionnode"
    end
end
