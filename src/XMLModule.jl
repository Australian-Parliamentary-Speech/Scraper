module XMLModule
using Reexport
@reexport using EzXML
@reexport using AndExport

using ..Utils

@xport function findall_in_subsoup(path,xpath,soup)
    return findall("$(path)$xpath",soup)
end

@xport function findfirst_in_subsoup(path,xpath,soup)
    return findfirst("$(path)$xpath",soup)
end

@xport function filter_node_content_by_paths(node,paths)
    content = ""
    path = node.path
    for child in nodes(node)
        if !(any(x -> x == child.path, paths))
            content *= child.content
        end
    end
    return clean_text(content)
end

@xport function clean_text(str::AbstractString)
    # Replace newline characters with an empty string
    filtered_str = replace(str, "\n" => "")
    # Replace multiple spaces with a single space, excluding spaces between words
    filtered_str = replace(filtered_str, r"\s+" => " ")
    if all(isspace, filtered_str)
        return "N/A"
    else
        return strip(lstrip(filtered_str))
    end
end


end
