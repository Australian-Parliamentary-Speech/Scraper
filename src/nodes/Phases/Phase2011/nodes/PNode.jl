function get_xpaths(::Type{PNode{Phase2011}})
    return ["para"]
end

function get_sections(::Type{PNode{Phase2011}})
    return [Node{<:SpeechNode},Node{<:QuestionNode},Node{<:AnswerNode},Node{<:BusinessNode},Node{<:InterjectionNode},Node{<:MotionnospeechNode},Node{<:DebateNode},Node{<:QuoteNode_}]
end


function is_first_node_type(node::Node{PNode{Phase2011}},parent_node,allowed_names,node_tree)
    if typeof(parent_node) <: Node{<:MotionnospeechNode}
        return true
    end
    try
        return nodename(prevnode(prevnode(node.node))) == "talker"
    catch
        return false
    end
end

