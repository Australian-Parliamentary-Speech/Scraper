export SpeechNode

abstract type SpeechNode <: Node end

function is_nodetype(node, node_tree,::Type{SpeechNode}, args...; kwargs...)
    year = kwargs[1]
    allowed_names = get_xpaths(year,SpeechNode)
    name = nodename(node)
    title = find_debate_title(node,node_tree)
    if title != "QUESTIONS WITHOUT NOTICE"
        return name in allowed_names
    else 
        return false
    end
end

function get_xpaths(year,::Type{SpeechNode})
    function year_to_phase(year)
        if 2020 < year < 2024
            return :phase1
        else
            @error "No phase was produced in speechnode"
        end
    end
    phase_to_dict = Dict(
                        :phase1 => ["speech","question","answer"]) 
    return  phase_to_dict[year_to_phase(year)]
end

