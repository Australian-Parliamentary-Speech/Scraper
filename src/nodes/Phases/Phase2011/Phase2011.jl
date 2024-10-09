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


"""
define_flags(node::Node{<:AbstractNode{Phase2011}},parent_node,node_tree)

Added petition and quote nodes on top of the previous flags
"""
function define_flags(node::Node{<:AbstractNode{Phase2011}},parent_node,node_tree)
    ParentTypes = [QuestionNode,AnswerNode,InterjectionNode,SpeechNode,PetitionNode,QuoteNode_{Phase2011}]
#    if parent_node isa Node{QuoteNode_{Phase2011}} && !(node_tree[end-1] isa Node{DebateNode{Phase2011}})
#        parent_node = node_tree[end-1]
#    end
    headers = ["question_flag","answer_flag","interjection_flag","speech_flag","petition_flag","quote_flag"]
    flags = map(node_type -> parent_node isa Node{<:node_type} ? 1 : 0, ParentTypes)
    header_and_flag = zip(headers,flags)
    for couple in header_and_flag
        node.headers_dict[couple[1]] = couple[2]
    end
    chamber = find_chamber(node,node_tree)
end


function define_headers(::Type{Phase2011})
    headers = ["question_flag","answer_flag","interjection_flag","speech_flag","petition_flag","quote_flag","chamber_flag","name","name.id","electorate","party","role","page.no","content","subdebateinfo","debateinfo","path"]
    headers_dict = OrderedDict(headers .=> ["N/A" for h in headers])
    return headers_dict
end


