function get_xpaths(::Type{PNode{PhaseOne}})
    return ["para"]
end

function get_sections(::Type{PNode{PhaseOne}})
    return [Node{<:SpeechNode},Node{<:QuestionNode},Node{<:AnswerNode},Node{<:BusinessNode},Node{<:InterjectionNode}]
end


function is_first_node_type(node::Node{PNode{PhaseOne}},parent_node,allowed_names,node_tree)
    try
        return nodename(prevnode(prevnode(node.node))) == "talker"
    catch
        return false
    end
end

