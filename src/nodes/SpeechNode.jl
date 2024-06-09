export SpeechNode

abstract type SpeechNode{P} <: AbstractNode{P} end



function is_nodetype(node, node_tree,nodetype::Type{<:SpeechNode},phase::Type{<:AbstractPhase},soup, args...; kwargs...)
    nodetype = nodetype{phase}
    allowed_names = get_xpaths(nodetype)
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

function get_xpaths(::Type{<:SpeechNode})
    return ["speech","question","answer"]
end


