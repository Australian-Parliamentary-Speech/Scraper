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
    speech_node = findfirst("//speech",soup)
    talk_node = findfirst("$(speech_node.path)//talk.start",soup)
    @show talk_node.content

    node = Node(talk_node,1,1.0,soup)
    talker = get_talker_from_parent(node)
    @show talker
end
 
