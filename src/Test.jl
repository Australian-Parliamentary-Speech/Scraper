using EzXML

include("Utils.jl")
using .Utils

include("XMLModule.jl")
using .XMLModule


struct Node
    node::EzXML.Node
    index::Int64
    date::Float64
    soup
end

function test()
    fn = "../Inputs/hansard/xmls/2011/2011-02-08.xml"
    xdoc = readxml(fn)
    soup = root(xdoc)
    speech_node = findfirst("//speech/talk.start",soup)
    @show [nodename(i) for i in elements(speech_node)]
    para_node = findfirst("$(speech_node.path)//para",soup)
    @show para_node.content
    @show nodename(prevnode(para_node))
    @show nodename(prevnode(prevnode(para_node)))


#    node = Node(talk_node,1,1.0,soup)
#    talker = get_talker_from_parent(node)
#    @show talker
end
 
