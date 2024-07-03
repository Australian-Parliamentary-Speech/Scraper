export MotionnospeechNode

abstract type MotionnospeechNode{P} <: AbstractNode{P} end


function get_xpaths(::Type{MotionnospeechNode{PhaseOne}})
    return ["motionnospeech"]
end

