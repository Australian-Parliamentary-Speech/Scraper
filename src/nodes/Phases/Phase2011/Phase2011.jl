# Define like this to ensure Phase exists before including node overrides
abstract type Phase2011 <: AbstractPhase end

# Get Phase Node Overrides
phase_node_path = joinpath(@__DIR__, "nodes")

for path in readdir(phase_node_path, join=true)
    if isfile(path)
        include(path)
    end
end

# Uncomment to test
upperbound = date_to_float(2011,4,0)
date_to_phase[(1901.0,upperbound)] = Phase2011


function define_flags(node::Node{<:AbstractNode{Phase2011}},parent_node,node_tree)
    ParentTypes = [QuestionNode,AnswerNode,InterjectionNode,SpeechNode,PetitionNode]
    if parent_node isa Node{QuoteNode_{Phase2011}} && !(node_tree[end-1] isa Node{DebateNode{Phase2011}})
        parent_node = node_tree[end-1]
    end
    flags = map(node_type -> parent_node isa Node{<:node_type} ? 1 : 0, ParentTypes)
    chamber = find_chamber(node,node_tree)
    push!(flags,chamber)
    return flags
end


function find_headers(::Type{Phase2011})
    return ["question_flag","answer_flag","interjection_flag","speech_flag","petition_flag","chamber_flag","name","name.id","electorate","party","role","page.no","content","subdebateinfo","debateinfo","path"]
end


