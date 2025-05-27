# Define like this to ensure Phase exists before including node overrides
abstract type Phase2011 <: AbstractPhase end

# Get Phase Node Overrides
phase_node_path = joinpath(@__DIR__, "nodes")

for path in readdir(phase_node_path, join=true)
    if isfile(path)
        include(path)
    end
end

upperbound = date_to_float(2011,4,0)
upperbound2 = date_to_float(1980,12,12)
date_to_phase[(1998.0,upperbound)] = Phase2011
date_to_phase[(1901.0,upperbound2)] = Phase2011

function free_node_parent_types(node::Node{<:AbstractNode{Phase2011}})
    return [DebateNode,SubdebateNode,SpeechNode]
end

"""
define_flags(node::Node{<:AbstractNode{Phase2011}},parent_node,node_tree)

Added petition and quote nodes on top of the previous flags
"""
function define_flags(node::Node{<:AbstractNode{Phase2011}},parent_node,node_tree)
    ParentTypes = [QuestionNode,AnswerNode,InterjectionNode,SpeechNode,PetitionNode,QuoteNode_{Phase2011},MotionnospeechNode]
#    if parent_node isa Node{QuoteNode_{Phase2011}} && !(node_tree[end-1] isa Node{DebateNode{Phase2011}})
#        parent_node = node_tree[end-1]
#    end
    headers = ["question_flag","answer_flag","interjection_flag","speech_flag","petition_flag","quote_flag","motionnospeech_flag"]
    flags = map(node_type -> parent_node isa Node{<:node_type} ? 1 : 0, ParentTypes)
    header_and_flag = zip(headers,flags)
    for couple in header_and_flag
        node.headers_dict[couple[1]] = couple[2]
    end
    chamber = find_chamber(node,node_tree)
end


function define_headers(::Type{Phase2011})
    headers = ["question_flag","answer_flag","interjection_flag","speech_flag","petition_flag","quote_flag","motionnospeech_flag","chamber_flag","name","name.id","electorate","party","role","page.no","content","subdebateinfo","debateinfo","path"]
    headers_dict = OrderedDict(headers .=> ["N/A" for h in headers])
    return headers_dict
end



