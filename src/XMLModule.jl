module XMLModule
using Reexport
using AndExport
@reexport using EzXML

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

@xport function get_talker_from_parent(parent_node)
    @info parent_node.node.path
    soup = parent_node.soup
    parent_node = parent_node.node
    talker_node = findfirst_in_subsoup(parent_node.path,"//talker",soup)
    function find_content(xpath)
        talker_content_node = findfirst_in_subsoup(talker_node.path,xpath,soup)
        if isnothing(talker_content_node)
            return "N/A"
        else
            return talker_content_node.content
        end
    end

    talker_xpaths = ["//name","//name.id","//electorate","//party","//role","//page.no"]
    if isnothing(talker_node)
        return ["N/A" for i in 1:length(talker_xpaths)]
    else
        talker_contents = []
        for xpath in talker_xpaths
            talker_content = find_content(xpath)
            push!(talker_contents,talker_content)
        end
        return talker_contents
    end
end


end
