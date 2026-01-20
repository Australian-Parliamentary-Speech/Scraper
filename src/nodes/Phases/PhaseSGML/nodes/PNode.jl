"""
get_xpaths(::Type{PNode{PhaseSGML}})

"para" as accepted xpaths for PNode.
"""
function get_xpaths(::Type{PNode{PhaseSGML}})
    return ["para"]
end

"""
get_sections(::Type{PNode{PhaseSGML}})

Allowed sections for PNodes.
"""
function get_sections(::Type{PNode{PhaseSGML}})
    return [Node{<:SpeechNode},Node{<:QuestionNode},Node{<:AnswerNode},Node{<:BusinessNode},Node{<:InterjectionNode},Node{<:MotionnospeechNode},Node{<:DebateNode},Node{<:QuoteNode_},Node{<:PetitionNode},Node{<:InterTalkNode}]
end

function is_first_node_type(node::Node{PNode{PhaseSGML}},parent_node,allowed_names,node_tree)
    if typeof(parent_node) <: Node{<:MotionnospeechNode}
        return true
    end

    if !hasprevnode(node.node)
       return true
    end
    
    if hasprevnode(prevnode(node.node))
        if nodename(prevnode(prevnode(node.node))) == "talker" || nodename(prevnode(prevnode(node.node))) == "talk.start"
           return true
        else
            return false
        end
    else
        return false
    end

end


function is_nodetype(node, node_tree, nodetype::Type{<:PNode},phase::Type{PhaseSGML},soup, args...; kwargs...) 
    nodetype = nodetype{phase}
    allowed_names = get_xpaths(nodetype)
    name = nodename(node)
    if name in allowed_names
        if length(node_tree) == 0
            return true
        else
            section_types = get_sections(nodetype)
            parent_node = node_tree[end]
            is_parent = any(section_node -> (typeof(parent_node) <: section_node), section_types)
            return is_parent
        end
    else
        return false
    end
end


function process_node(node::Node{PNode{PhaseSGML}},node_tree)
    nodetype = typeof(node).parameters[1]
    allowed_names = get_xpaths(nodetype)
    #    parent_node = reverse_find_first_node_not_name(node_tree,allowed_names)
    if length(node_tree) > 0
#        parent_node = node_tree[end]
        parent_node = find_p_node_parent(node,node_tree)
        if is_first_node_type(node,parent_node,allowed_names,node_tree)
            get_talker_from_parent(node,parent_node)
            if node.headers_dict["name"] == "N/A"
                name = findfirst_in_subsoup(parent_node.node.path,"//name",node.soup)
                if !isnothing(name)
                    node.headers_dict["name"] = name.content
                end
            end
        end
        define_flags(node,parent_node,node_tree)
    else
        define_flags(node,node,node_tree)
    end
    return construct_row(node,node_tree)
end



