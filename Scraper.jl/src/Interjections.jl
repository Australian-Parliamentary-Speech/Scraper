module Interjections

using utils
using AndExport

@xport function get_interjections(path,soup)
    inter_nodes = findall("$(path)//interjection",soup)
    return inter_nodes
end

end
