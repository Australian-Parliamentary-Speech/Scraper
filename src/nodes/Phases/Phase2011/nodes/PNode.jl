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
        write_test_xml(node,parent_node,"is_first_p_node_motionnospeech")
        return true
    end
    
    if hasprevnode(prevnode(node.node))
        if nodename(prevnode(prevnode(node.node))) == "talker"
            write_test_xml(node,parent_node,"is_first_p_node_talker") 
            return true
        else
            write_test_xml(node,parent_node,"do_not_find_talker_in_parent") 
            return false
        end
    else
        return false
    end
end


function is_nodetype(node, node_tree, nodetype::Type{<:PNode},phase::Type{Phase2011},soup, args...; kwargs...) 
    nodetype = nodetype{phase}
    allowed_names = get_xpaths(nodetype)
    name = nodename(node)
    if name in allowed_names
        if length(node_tree) == 0
            @info "para without parent detected"
            dummy_node = Node{AbstractNode{phase}}(node,1,0.0,soup)
            parent_node = Node{AbstractNode{phase}}(soup,1,0.0,soup)
            edge_case = "para_without_parent" 
            write_test_xml(dummy_node,parent_node,edge_case) 
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


function process_node(node::Node{PNode{Phase2011}},node_tree)
    nodetype = typeof(node).parameters[1]
    allowed_names = get_xpaths(nodetype)
    #    parent_node = reverse_find_first_node_not_name(node_tree,allowed_names)
    if length(node_tree) > 0
        parent_node = node_tree[end]
        if is_first_node_type(node,parent_node,allowed_names,node_tree)
            talker_contents = get_talker_from_parent(nodetype,parent_node)
            if all(i->(i=="N/A"), talker_contents)
                name = findfirst_in_subsoup(parent_node.node.path,"//name",node.soup)
                if !isnothing(name)
                    talker_contents[1] = name.content
                end
            end

        else
            talker_contents = find_talker_in_p(node)
        end

        flags = define_flags(node,parent_node,node_tree)
    else
        talker_contents = ["N/A" for i in 1:6]
        flags = define_flags(node,node,node_tree)
    end
    return construct_row(node,node_tree,flags,talker_contents,node.node.content)
end


function find_talker_in_p(p_node::Node{PNode{Phase2011}})
    p_talker = findfirst_in_subsoup(p_node.node.path,"//a",p_node.soup)
    if isnothing(p_talker)
        content = clean_text(p_with_a_as_parent(p_node))
        return [content,"N/A","N/A","N/A","N/A","N/A"]
    else
        return [clean_text(p_talker.content),"N/A","N/A","N/A","N/A","N/A"]
    end
end


