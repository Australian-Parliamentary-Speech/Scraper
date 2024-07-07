export MotionnospeechNode

abstract type MotionnospeechNode{P} <: AbstractNode{P} end


function get_xpaths(::Type{MotionnospeechNode{Phase2011}})
    return ["motionnospeech"]
end

