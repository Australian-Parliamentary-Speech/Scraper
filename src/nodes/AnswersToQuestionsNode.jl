export AnswersToQuestionsNode

abstract type AnswersToQuestionsNode{P} <: AbstractNode{P} end

function get_xpaths(::Type{<:AnswersToQuestionsNode})
    return ["answers.to.questions"]
end


