export SpeechNode

abstract type SpeechNode <: AbstractNode end



function is_nodetype(node, node_tree,::Type{SpeechNode}, args...; kwargs...)
    year = kwargs[:year]
    soup = args[1]
    allowed_names = get_xpaths(year,SpeechNode)
    name = nodename(node)
    try
        title = find_debate_title(node,node_tree,soup)
        if title != "QUESTIONS WITHOUT NOTICE"
            return name in allowed_names
        else 
            return false
        end
    catch e
        @error e
        return false
    end
end

function get_xpaths(year,::Type{SpeechNode})
    phase_to_dict = Dict(
                         :phase1 => ["speech","question","answer"]) 
    return  phase_to_dict[year_to_phase(year)]
end


