function get_xpaths(::Type{PNode{PhaseOne}})
    return ["para"]
end

function get_sections(::Type{PNode{PhaseOne}})
    return [Node{<:SpeechNode},Node{<:QuestionNode},Node{<:AnswerNode},Node{<:BusinessNode},Node{<:InterjectionNode},Node{<:MotionnospeechNode}]
end


function is_first_node_type(node::Node{PNode{PhaseOne}},parent_node,allowed_names,node_tree)
    if typeof(parent_node) <: Node{<:MotionnospeechNode}
        return true
    end
    try
        return nodename(prevnode(prevnode(node.node))) == "talker"
    catch
        return false
    end
end

