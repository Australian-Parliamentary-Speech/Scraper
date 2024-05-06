module Speeches
using Parameters
using EzXML
using AndExport
using utils
using scrape_utils
using write_utils
using load_set_up

@xport function get_all_speech_debate_keys(run_)
    @unpack section_xpaths = run_
    return filter(x -> x != "QUESTIONS WITHOUT NOTICE", collect(keys(section_xpaths)))
end

@xport function get_speech_subdebate_nodes(debate_path,soup,run_)
    @unpack xpaths = run_
    subdebateinfo_nodes = find_in_subsoup(debate_path,soup,xpaths["SUBDEBATE"],:all)
    subdebate_nodes = [parentnode(subdebateinfo_node) for subdebateinfo_node in subdebateinfo_nodes]
    return subdebate_nodes
end

@xport function get_speech_nodes(subdebate_node,soup,run_)
    @unpack xpaths = run_
    speech_xpath = xpaths["SPEECH"]
    speech_nodes = find_in_subsoup(subdebate_node.path,soup,speech_xpath,:all)
    return speech_nodes
end


end
