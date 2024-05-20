export PNode

abstract type PNode <: Node end

#args is a list, kwargs is a dictionary
function is_nodetype(node, node_tree, ::Type{PNode}, args...; kwargs...)
    year = kwargs[1]
    allowed_names = get_xpaths(year,PNode)
    name = nodename(node)
    return name in allowed_names
end

#is_nodetype(node, node_tree, NodeType, a, b, c; d=1, e=3)

function get_xpaths(year,::Type{PNode})
    function year_to_phase(year)
        if 2020 < year < 2024
            return :phase1
        else
            @error "No phase was produced in speechnode"
        end
    end
    phase_to_dict = Dict(
                        :phase1 => ["p"]) 
    return  phase_to_dict[year_to_phase(year)]
end
