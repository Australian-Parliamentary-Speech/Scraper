export SkipNode

abstract type SkipNode{P} <: AbstractNode{P} end

function get_xpaths(::Type{<:SkipNode})
    return ["debate"]
end


function is_nodetype(node,node_tree,nodetype::Type{<:SkipNode},phase::Type{<:AbstractPhase},soup)
    nodetype = nodetype{phase}
    allowed_names = get_xpaths(nodetype)
    name = nodename(node)
    if name in allowed_names
        debateinfo_path = get_section_title_path(DebateNode)
        title = findfirst_in_subsoup(node.path,debateinfo_path,soup)
        return title.content in ["BILLS"]
    else
        return false
    end
end

