module utils
using AndExport
using RegularExpressions

@xport function remove_the_speaker(text)
    # Define regular expression pattern to match "(The SPEAKER)"
    pattern = r"\(The\s+SPEAKER\)"
    
    # Replace the matched pattern with an empty string
    cleaned_text = replace(text, pattern => "")
    
    return cleaned_text
end


@xport function Float_(value)
    return parse(Float64, value)
end

@xport function has_nothing(lst)
    return any(x -> x === nothing, lst)
end

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
    function find_content(xpath)
        talker_content_node = findfirst("$(talker_node.path)//$(xpath)",talker_node)
        #        @show talker_content_node.path
        talker_content = talker_content_node.content
        return talker_content
    end

    talker_contents = []
    for xpath in ["name","name.id","electorate","party"]
        talker_content = find_content(xpath)
        if xpath == "name"
#            @show talker_node.path
#            @show talker_content
        end
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
    return findall("$nodename", soup)
end

@xport function filter_(str::AbstractString)
    # Replace newline characters with an empty string
    filtered_str = replace(str, "\n" => "")
    # Replace multiple spaces with a single space, excluding spaces between words
    filtered_str = replace(filtered_str, r"\s+" => " ")
    return filtered_str
end


#@xport function extract_number(input_string::AbstractString)
#    pattern = r"\d+"
#    match_ = match(pattern, input_string)
#    if match_ != nothing
#        return parse(Int, match_.match)
#    else
#        print("No numbers found")
#    end
#end


@xport function find_in_subsoup(path,soup,xpath,all_or_first)
    if all_or_first == :all
        return findall("$(path)$xpath",soup)
    elseif all_or_first == :first
        return findfirst("$(path)$xpath",soup)
    end
end


@xport function read_csv_columns(filename::AbstractString, column_indice::Int)
    df = CSV.File(filename) |> DataFrame
    column = df[:, i]
    return column
end

@xport function create_dict_multiple_values(keys,values)
    dict_ = Dict()
    past_keys = []
    for i in 1:length(keys)
        key = keys[i]
        value = values[i]
        if !(key in past_keys)
            dict_[key] = [value]
        elseif key in past_keys
            prev_value = dict_[key]
            push!(prev_value,value)
            dict_[key] = prev_value
        end
        push!(past_keys,key)
    end
    return dict_
end



end
