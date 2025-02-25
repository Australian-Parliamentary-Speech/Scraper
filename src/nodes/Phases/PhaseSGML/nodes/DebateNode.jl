function get_section_title_path(::Type{DebateNode{PhaseSGML}})
    return "/title"
end


function get_xpaths(::Type{DebateNode{PhaseSGML}})
#    return ["qwn"]
    return ["debate","qwn","answer.to.qon"]
end

