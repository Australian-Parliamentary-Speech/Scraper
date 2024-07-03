function get_xpaths(::Type{PNode{PhaseOne}})
    return ["para"]
end

function get_sections(::Type{PNode{PhaseOne}})
    return [Node{<:SpeechNode},Node{<:QuestionNode},Node{<:AnswerNode},Node{<:BusinessNode},Node{<:InterjectionNode}]
end
