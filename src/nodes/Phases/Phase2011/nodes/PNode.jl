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
    return [Node{<:SpeechNode},Node{<:QuestionNode},Node{<:AnswerNode},Node{<:BusinessNode},Node{<:InterjectionNode},Node{<:MotionnospeechNode},Node{<:DebateNode},Node{<:QuoteNode_},Node{<:PetitionNode},Node{<:InterTalkNode},Node{<:SubdebateNode},Node{<:AdjournmentNode}]
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
    if !hasprevnode(node.node)
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
#            dummy_node = Node{AbstractNode{phase}}(node,1,0.0,soup,OrderedDict("a"=>0))
#            dummy_parent_node = Node{AbstractNode{phase}}(soup,1,0.0,soup, OrderedDict("a"=>0))
#            edge_case = "para_without_parent" 
#            write_test_xml(dummy_node,dummy_parent_node,edge_case) 
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
    edge_case = nothing
    if length(node_tree) > 0
        parent_node = node_tree[end]
        c = node.node.content
        get_talker_from_parent(node,parent_node)
        if node.headers_dict["name.id"] == "N/A"
            name = findfirst_in_subsoup(parent_node.node.path,"//name",node.soup)
            if !isnothing(name)
                node.headers_dict["name"] = name.content
            end
            if node.headers_dict["name"] == "N/A"
                find_talker_in_p(node)
            end
        end
        define_flags(node,parent_node,node_tree)
    else
        define_flags(node,node,node_tree)
    end
    return construct_row(node,node_tree)
end




