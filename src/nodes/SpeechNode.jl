export SpeechNode

abstract type SpeechNode{P} <: AbstractNode{P} end



function is_nodetype(node, node_tree,nodetype::Type{<:SpeechNode},phase::Type{<:AbstractPhase},soup, args...; kwargs...)
    nodetype = nodetype{phase}
    allowed_names = get_xpaths(nodetype)
    name = nodename(node)
    try
        title = find_section_title(node_tree,soup,DebateNode)
        if title != "QUESTIONS WITHOUT NOTICE"
            if name == "motionnospeech"
            end
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


