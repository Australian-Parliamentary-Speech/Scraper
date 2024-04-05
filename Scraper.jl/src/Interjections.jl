module Interjections

using utils
using AndExport

@xport function get_interjections(path,soup)
    inter_nodes = find_in_subsoup(path,soup,"//interjection",:all)
#    inter_nodes = findall("$(path)//interjection",soup)
    return inter_nodes
end

@xport function interjector_name(inter_speaker)
    if occursin("interjecting", inter_speaker)
        return remove_the_speaker(string(match(r"(.+?)\s+interjecting—", inter_speaker).captures[1]))
    else
        return remove_the_speaker(inter_speaker)
    end
end

end
