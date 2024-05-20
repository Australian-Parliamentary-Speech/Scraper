export DebateNode

abstract type DebateNode <: Node end


function is_nodetype(node, node_tree, ::Type{DebateNode}, args...; kwargs...)
    year = kwargs[1]
    allowed_names = get_xpaths(year,DebateNode)
    name = nodename(node)
    return name in allowed_names
end


function get_xpaths(year,::Type{DebateNode})
    function year_to_phase(year)
        if 2020 < year < 2024
            return :phase1
        else
            @error "No phase was produced in speechnode"
        end
    end
    phase_to_dict = Dict(
                        :phase1 => ["debate"]) 
    return  phase_to_dict[year_to_phase(year)]
end
