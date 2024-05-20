export SpeechNode

abstract type SpeechNode <: Node end

function is_nodetype(node, node_tree,::Type{SpeechNode}, args...; kwargs...)
    year = kwargs[1]
    allowed_names = get_xpaths(typeof(node),year)
    name = nodename(node)
    title = find_debate_title(node)
    if title != "QUESTIONS WITHOUT NOTICE"
        if name in allowed_names
            return true
        end
    end
end

function get_xpaths(::Type{SpeechNode},year)
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

