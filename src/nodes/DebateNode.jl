export DebateNode

abstract type DebateNode{P} <: AbstractNode{P} end


function get_xpaths(::Type{<:DebateNode})
    return ["debate"]
end

function get_section_title_path(::Type{<:DebateNode})
    return "/debateinfo/title"
end

#function is_nodetype(node,node_tree,nodetype::Type{<:DebateNode},phase::Type{<:AbstractPhase},soup)
#    nodetype = nodetype{phase}
#    allowed_names = get_xpaths(nodetype)
#    name = nodename(node)
#    return name in allowed_names
##    if name in allowed_names
##        debateinfo_path = get_section_title_path(DebateNode)
##        title = findfirst_in_subsoup(node.path,debateinfo_path,soup)
##        return title.content != "BILLS"
##    else
##        return false
##    end
#end





