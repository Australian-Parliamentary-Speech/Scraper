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

        else
            find_talker_in_p(node)
        end
        define_flags(node,parent_node,node_tree)
    else
        define_flags(node,node,node_tree)
    end
    return construct_row(node,node_tree)
end



#function find_talker_in_p(p_node::Node{PNode{Phase2011}})
#    p_talker_soup = findfirst_in_subsoup(p_node.node.path,"//a",p_node.soup)
#    if isnothing(p_talker_soup)
#        p_with_a_as_parent(p_node)
#        if p_node.headers_dict["name"] == "N/A" || p_node.headers_dict["name.id"] == "N/A"
#            p_talker_inline = findfirst_in_subsoup(p_node.node.path,"//inline",p_node.soup)
#            if !isnothing(p_talker_inline)
#                potential_talker = p_talker_inline.content
#                content = p_node.node.content
#                if length(content) > 2*length(potential_talker)
#                    start = content[1:length(potential_talker)*2]
#                else
#                    start = content
#                end
#                name_ = strip(clean_text(p_talker_inline.content),['(',')'])
#                if occursin("Australian Financial Review",potential_talker) 
#                    @show start
#                end
#                if occursin(name_, start)
#                    if length(split(name_," "))< 4 && !(occursin(r"\d", name_))
#                        p_node.headers_dict["name"] = name_
#                    end
#                end
#            end
#        end
#    else
#        p_talker  = findfirst_in_subsoup(p_talker_soup.path,"/@type",p_node.soup)
#        p_talker_id = findfirst_in_subsoup(p_talker_soup.path,"/@href",p_node.soup)
#        p_talker = isnothing(p_talker) ? "N/A" : p_talker.content
#        p_talker_id = isnothing(p_talker_id) ? "N/A" : p_talker_id.content
#        p_node.headers_dict["name"] = clean_text(p_talker)
#        p_node.headers_dict["name.id"] = clean_text(p_talker_id)
#    end
#end
#
