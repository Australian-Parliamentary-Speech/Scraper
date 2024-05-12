module Speeches
using Parameters
using EzXML
using AndExport
using utils
using scrape_utils
using write_utils
using load_set_up
using Interjections

@xport function get_all_speech_debate_keys_ordered(run_)
    @unpack section_xpaths, general_option = run_
    function by_(ele)
        path = section_xpaths[ele][1]
        num = parse(Int, match(r"\[(\d+)\]", path).captures[end])
        return num
    end
    titles = filter(x -> x != "QUESTIONS WITHOUT NOTICE", collect(keys(section_xpaths)))
    return sort(titles,by=by_)
end

@xport function get_speech_subdebate_nodes(debate_path,soup,run_)
    @unpack xpaths = run_
    subdebateinfo_nodes = find_in_subsoup(debate_path,soup,xpaths["SUBDEBATE"],:all)
    subdebate_nodes = [parentnode(subdebateinfo_node) for subdebateinfo_node in subdebateinfo_nodes]
    return subdebate_nodes
end

@xport function get_wanted_nodes(subdebate_node,soup,run_)
    speech_nodes = get_speech_nodes(subdebate_node,soup,run_)
    other_nodes = get_other_nodes(subdebate_node,soup,run_)
    return speech_nodes,other_nodes
end

@xport function get_other_nodes(subdebate_node,soup,run_)
    subnodes = elements(subdebate_node)
    nodes_wanted = ["question","answer"]
    return [subnode for subnode in subnodes if subnode.name in nodes_wanted]
end

@xport function get_speech_nodes(subdebate_node,soup,run_,verbose=false)
    @unpack xpaths = run_
    function test(node)
        return !(node.name in["subdebate.text","subdebate.2","subdebateinfo"])
    end
    speech_xpath = xpaths["SPEECH"]
    speech_nodes = find_in_subsoup(subdebate_node.path,soup,speech_xpath,:all)
    if verbose == true
        if speech_nodes == []
            @show [element for element in elements(subdebate_node) if test(element)]
        end
    end
    return speech_nodes
end

#######writing into csv#################
@xport function separate_talk_subdiv_content_speech(node,soup,run_)
    return separate_talk_subdiv_content(node,soup,run_,:speech)
end


end
