module utils
using AndExport
using RegularExpressions

@xport function find_text(soup,content,delim=nothing)
    text_list = nodecontent.(findall("$content", soup))
    if split != nothing
        text_new_list = []
        for text in text_list
            push!(text_new_list,split(text,delim))
        end
    end
    return [filter(t) for t in text_list]        
end

@xport function find_node(soup,nodename)
    nodes = []
    for node in findall("$nodename", soup)
        push!(nodes,node)
    end    
    return nodes
end

@xport function filter_(str::AbstractString)
    # Replace newline characters with an empty string
    filtered_str = replace(str, "\n" => "")
    # Replace multiple spaces with a single space, excluding spaces between words
    filtered_str = replace(filtered_str, r"\s+" => " ")
    return filtered_str
end


@xport function extract_number(input_string::AbstractString)
    pattern = r"\d+"
    match_ = match(pattern, input_string)
    if match_ != nothing
        return parse(Int, match_.match)
    else
        print("No numbers found")
    end
end



end
