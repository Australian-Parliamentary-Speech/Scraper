module SpeechNode

struct SpeechNode <: Node
end

#nodes_wanted = ["question","answer"]
@xport function get_speech_nodes(subdebate_node,soup,run_)
    speech_node_names = run_.
    subnodes = elements(subdebate_node)
    return [subnode for subnode in subnodes if subnode.name in nodes_wanted]
end

@xport function get_speech_subdebate_nodes(debate_path,soup,run_)
    @unpack xpaths = run_
    subdebateinfo_nodes = find_in_subsoup(debate_path,soup,xpaths["SUBDEBATE"],:all)
    subdebate_nodes = [parentnode(subdebateinfo_node) for subdebateinfo_node in subdebateinfo_nodes]
    return subdebate_nodes
end


end
