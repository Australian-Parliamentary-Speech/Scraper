module Interjections

using utils
using AndExport
using load_set_up
using Parameters


@xport function get_interjections(path,soup,run_)
    @unpack xpaths = run_
    inter_nodes = find_in_subsoup(path,soup,xpaths["INTERJECTION"],:all)
#    inter_nodes = findall("$(path)//interjection",soup)
    return inter_nodes
end

@xport function get_interjection_content(inter_node,soup,run_)
    @unpack xpaths = run_
    inter_content_node = find_in_subsoup(inter_node.path,soup,xpaths["TALK_CONTENT"],:first)
    return filter_(inter_content_node.content)
end

@xport function interjection_edit(inter,run_)
    @unpack general_option = run_ 
    inter_speaker = inter[1]
    inter_content = inter[2]
    if general_option["TALKER_NAME_INTO_CONTENT"] == true
        if occursin("interjecting", inter_speaker[1])
            if inter_content != "N/A"
                inter_content = inter_content*inter_speaker[1]
            else
                inter_content = inter_speaker[1]
            end
            inter_speaker[1] = remove_the_speaker(string(match(r"(.+?)\s+interjecting—", inter_speaker[1]).captures[1]))
        end
    end

    return (inter_speaker,inter_content)
end

end
