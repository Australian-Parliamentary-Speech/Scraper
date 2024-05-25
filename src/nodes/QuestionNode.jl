export QuestionNode

abstract type QuestionNode <: AbstractNode end


function is_nodetype(node, node_tree,::Type{QuestionNode}, args...; kwargs...)
    year = kwargs[:year]
    soup = args[1]
    allowed_names = get_xpaths(year,QuestionNode)
    name = nodename(node)
    try
        title = find_debate_title(node,node_tree,soup)
        if title == "QUESTIONS WITHOUT NOTICE"
            return name in allowed_names
        else
            return false
        end
    catch
        return false
    end
end


function get_xpaths(year,::Type{QuestionNode})
   phase_to_dict = Dict(
                        :phase1 => ["question","answer"]) 
    return  phase_to_dict[year_to_phase(year)]
end


