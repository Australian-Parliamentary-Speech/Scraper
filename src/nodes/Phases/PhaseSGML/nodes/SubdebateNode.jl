function get_xpaths(::Type{SubdebateNode{PhaseSGML}})
    return ["subdebate.1","question.block"]
end

function get_section_title_path(::Type{SubdebateNode{PhaseSGML}})
    return "/title"
end
