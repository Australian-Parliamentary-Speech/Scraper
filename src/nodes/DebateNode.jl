export DebateNode

abstract type DebateNode{P} <: AbstractNode{P} end


function get_xpaths(::Type{<:DebateNode})
    return ["debate"]
end

function get_section_title_path(::Type{<:DebateNode})
    return "/debateinfo/title"
end




