module utils
using AndExport
using RegularExpressions

@xport function edit_row(row)
    edit_row = ' '
    for i in row
        edit_row = edit_row * "\"$i\","
    end
    return edit_row
end


@xport function get_talker(path,soup)
    talker_node = talker_from_any(path,soup)
    return talker_content(talker_node)
end

@xport function talker_from_any(path,soup)
    talker_node = findfirst("$(path)//talker",soup)
    return talker_node
end

@xport function talker_content(talker_node)
    function find_content(xpath,talker_node)
        talker_content_node = findfirst("$(talker_node.path)//$(xpath)",talker_node)
        #        @show talker_content_node.path
        talker_content = talker_content_node.content
        return talker_content
    end

    talker_contents = []
    for xpath in ["name","name.id","electorate","party"]
        talker_content = find_content(xpath,talker_node)
        push!(talker_contents,talker_content)
    end
    #        @show talker_name.parentnode.path
    return talker_contents
end

@xport function find_text(soup,xpath,delim=nothing)
    text_list = [i.content for i in findall("$xpath", soup)]
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


@xport function findall_in_subsoup(path,soup,xpath)
    nodes = findall("$(path)//$xpath",soup)
    return nodes
end


@xport function read_csv_columns(filename::AbstractString, column_indice::Int)
    df = CSV.File(filename) |> DataFrame
    column = df[:, i]
    return column
end


end
