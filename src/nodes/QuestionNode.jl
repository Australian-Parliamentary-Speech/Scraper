export QuestionNode

abstract type QuestionNode{P} <: AbstractNode{P} end


function is_nodetype(node, node_tree,nodetype::Type{<:QuestionNode},phase::Type{<:AbstractPhase},soup, args...; kwargs...)
    nodetype = nodetype{phase}
    allowed_names = get_xpaths(nodetype)
    name = nodename(node)
    try
        title = find_section_title(node,node_tree,soup,DebateNode)
        if title == "QUESTIONS WITHOUT NOTICE"
            return name in allowed_names
        else
            return false
        end
    catch
        return false
    end
end


function get_xpaths(::Type{<:QuestionNode})
   return ["question"]
end

