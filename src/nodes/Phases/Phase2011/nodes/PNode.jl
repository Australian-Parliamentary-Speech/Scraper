"""
get_xpaths(::Type{PNode{Phase2011}})

"para" as accepted xpaths for PNode.
"""
function get_xpaths(::Type{PNode{Phase2011}})
    return ["para"]
end

"""
get_sections(::Type{PNode{Phase2011}})

Allowed sections for PNodes.
"""
function get_sections(::Type{PNode{Phase2011}})
    return [Node{<:SpeechNode},Node{<:QuestionNode},Node{<:AnswerNode},Node{<:BusinessNode},Node{<:InterjectionNode},Node{<:MotionnospeechNode},Node{<:DebateNode},Node{<:QuoteNode_},Node{<:PetitionNode}]
end

"""
is_first_node_type(node::Node{PNode{Phase2011}},parent_node,allowed_names,node_tree)

A different method to detect if the pnode is the first pnode for this phase
"""
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

