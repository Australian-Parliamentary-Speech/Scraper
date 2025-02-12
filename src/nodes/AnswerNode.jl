export AnswerNode

abstract type AnswerNode{P} <: AbstractNode{P} end


function is_nodetype(node, node_tree,nodetype::Type{<:AnswerNode},phase::Type{<:AbstractPhase},soup, args...; kwargs...)
    nodetype = nodetype{phase}
    allowed_names = get_xpaths(nodetype)
    name = nodename(node)
    try
        #find the debate title
        title = find_section_title(node_tree,soup,DebateNode{phase})
        if title == "QUESTIONS WITHOUT NOTICE"
            return name in allowed_names
        else
            return false
        end
    catch
        return false
    end
end


function get_xpaths(::Type{<:AnswerNode})
   return ["answer"]
end

