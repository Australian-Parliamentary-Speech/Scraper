abstract type QuestionNode <: Node end

function is_nodetype(node, node_tree,::QuestionNode, args...; kwargs...)
    allowed_names = args[1]
    name = nodename(node)
    title = find_debate_title(node)
    if title == "QUESTIONS WITHOUT NOTICE"
        if name in allowed_names
            return true
        end
    end
end



#parse(year)
#if year in range
#    parse_1990s
