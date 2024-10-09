export QuestionNode

abstract type QuestionNode{P} <: AbstractNode{P} end


function is_nodetype(node, node_tree,nodetype::Type{<:QuestionNode},phase::Type{<:AbstractPhase},soup, args...; kwargs...)
    nodetype = nodetype{phase}
    allowed_names = get_xpaths(nodetype)
    name = nodename(node)
    title = find_section_title(node,node_tree,soup,DebateNode)
    if name in allowed_names
        if title == "QUESTIONS WITHOUT NOTICE"
            return true
        else
            if length(node_tree)>0
                dummy_node = Node{AbstractNode{phase}}(node,1,0.0,soup,OrderedDict("a" => 0))
                parent_node = node_tree[end-1]
                edge_case = "question_node_not_question_time"
                write_test_xml(dummy_node,parent_node,edge_case)
            end
            return false
        end
    else
        return false
    end
end


function get_xpaths(::Type{<:QuestionNode})
   return ["question"]
end


