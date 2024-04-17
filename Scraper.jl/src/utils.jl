module utils
using AndExport
using RegularExpressions
using Scraper
using Parameters
using EzXML

@xport function get_dict(soup,xpath,set_key)
    nodes = find_node(soup,xpath)
    n_ids = [set_key(n.path) for n in nodes]
    n_dict = create_dict_multiple_values(n_ids,nodes)
    return n_dict
end


@xport function Float_(value)
    return parse(Float64, value)
end

@xport function has_nothing(lst)
    return any(x -> x === nothing, lst)
end

@xport function get_talker(path,soup,run_)
    talker_node = talker_from_any(path,soup,run_)
    return talker_content(talker_node)
end

@xport function talker_from_any(path,soup,run_)
    @unpack xpaths = run_
    talker_node = findfirst("$(path)$(xpaths["TALKER"])",soup)
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
    if all(isspace, filtered_str)
        return "N/A"
    else
        return strip(lstrip(filtered_str))
    end
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

@xport function get_all_text_minus_nodes(node,minus_node_paths)
    content = ""
    path = node.path
    for child in nodes(node)
        if !(any(x -> x == child.path, minus_node_paths))
            content *= child.content
        end
    end
    return filter_(content)
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

@xport function sort_based_on_order(list_to_sort, order_indices)
    function by_(ele)
        if haskey(order_indices, ele) 
            return order_indices[ele] 
        else
            throw(ErrorException("No key is found"))
        end
    end
    return sort(list_to_sort, by=by_)
end

end
