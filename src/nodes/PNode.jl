export PNode
#export process_node

# abstract type Phase end
# abstract type Phase1901_1910 <: Phase end
# 
# abstract type PNode{P <: Phase} <: AbstractNode end
# 
# function f(node::Node{PNode{Phase1901_1910}}) end
# function f(node::Node{PNode}) end
# function f(node::Node) end


abstract type PNode <: AbstractNode end

function process_node(node::Node{PNode},node_tree)
    allowed_names = get_xpaths(node.year,PNode)
    parent_node = reverse_find_first_node_not_name(node_tree,allowed_names)
    if is_first_node_type(node,parent_node,allowed_names)
        parent_node_ = node_tree[end]
        @assert parent_node_ == parent_node
        talker_contents = get_talker_from_parent(parent_node)
    else
        talker_contents = find_talker_in_p(node)
    end 
    flags = define_flags(parent_node)
    return construct_row(flags,talker_contents,node.node.content)
end

#args is a list, kwargs is a dictionary

function get_xpaths(year,::Type{PNode})
   phase_to_dict = Dict(
                        :phase1 => ["p"]) 
    return  phase_to_dict[year_to_phase(year)]
end

function get_sections(year,::Type{PNode})
   phase_to_dict = Dict(
                        :phase1 => ["speech","answer","question","business.start"]) 
    return  phase_to_dict[year_to_phase(year)]
end




