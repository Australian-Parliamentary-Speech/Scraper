export SubdebateNode

abstract type SubdebateNode{P} <: AbstractNode{P} end


function get_xpaths(::Type{<:SubdebateNode})
    return ["subdebate.1"]
end

function get_section_title_path(::Type{<:SubdebateNode})
    return "/subdebateinfo/title"
end
