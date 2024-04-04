module Interjections

using utils
using AndExport

@xport function get_interjections(path,soup)
    inter_nodes = find_in_subsoup(path,soup,"//interjection",:all)
#    inter_nodes = findall("$(path)//interjection",soup)
    return inter_nodes
end

end
