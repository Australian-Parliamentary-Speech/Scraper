module XMLModule
using Reexport
using AndExport
@reexport using EzXML

using ..Utils

@xport function clean_xml_names(xml_paths)
    function add_zero(str)
        if length(str) == 1
            return "0$str"
        end
        return str
    end
    cleaned_xml_paths = []
    for xml_path in xml_paths
        xml_path_ = xml_path[2]
        fn = basename(xml_path_)
        dir = dirname(xml_path_)
        m = match(r"(\d+)[_](\d+)[_](\d+)\.xml", fn)
        first,second,third = m.captures
        if length(first) < 4 && length(third) == 4
            year = third
            day = add_zero(first)
            month = add_zero(second)
       elseif length(first) == 4
            year = first
            month = add_zero(second)
            day = add_zero(third)
       else
            @debug "xml name $(xml_path_) has invalid date format"
        end
        cleaned_fn = "$(year)_$(month)_$(day).xml"
        cleaned_xml_path = joinpath(dir,cleaned_fn)
        push!(cleaned_xml_paths,(year,cleaned_xml_path))
        if xml_path_ != cleaned_xml_path
            command = `mv $(xml_path_) $(cleaned_xml_path)`
            run(command)
        end
    end
    return cleaned_xml_paths
end

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


#function pair_quotes(s)
##    s = replace(s, "'" => '\"')
##    single_quote_count = count(c -> c == '\'', s)
##    double_quote_count = count(c -> c == '"', s)
##    s = replace(s, '\'' => "")
##    s = replace(s, '"' => "")
#    return s
#end
#
@xport function clean_name(str::AbstractString)
    str = clean_text(str)
    unwanted_char = ["(",")",".","-"]
    for char in unwanted_char
        str = replace(str, char => "")
    end
    return str
end

@xport function clean_text(str::AbstractString)
    # Replace newline characters with an empty string
    filtered_str = replace(str, "\n" => "")

#    filtered_str = replace.(str, r"^[ \.]?-+" => "")
    # Replace multiple spaces with a single space, excluding spaces between words
    filtered_str = replace(filtered_str, r"\s+" => " ")
    if all(isspace, filtered_str)
        return "N/A"
    else
        return strip(lstrip(filtered_str))
    end
end

##########################################

function match_open_tags(fn::String)
    open_tags, close_tags = extract_tags(fn)
    open_names, close_names = @. tag_to_name(open_tags, "open"), @. tag_to_name(close_tags, "close")
    missing_names = missing_tags(open_names, close_names)
end

function remove_list!(lo, lc)
    for c in lc
        idx = findfirst(==(c), lo)
        if idx !== nothing
            deleteat!(lo, idx)
        end
    end
    return lo
end

function missing_tags(open_names,close_names)
    missing_names = remove_list!(open_names,close_names)
    return missing_names
end


function get_open_tags(xml::String)
    open_tags = String[]
    open_re = r"<([A-Za-z0-9_:.-]+)(\s[^>]*)?>"
    for m in eachmatch(open_re, xml)
        # If it is NOT self-closing, count it as opening tag
        if !endswith(strip(String(m.match)), "/>")
            push!(open_tags, m.match)
        end
    end
    return open_tags
end

function extract_tags(fn)
    xml = read(fn, String)
    close_tags = String[]
    close_re = r"</([A-Za-z0-9_:.-]+)\s*>"

    for m in eachmatch(close_re, xml)
        push!(close_tags, m.match)
    end

    open_tags = get_open_tags(xml)
    lo, lc = length(open_tags), length(close_tags)
    if lo != lc
        @info "tags not closed properly"
        @info lo, lc
    end
    return open_tags, close_tags 
end

function name_to_open(name)
    return "<$name>"
end

function name_to_close(name)
    return "</$name>"
end

function tag_to_name(tag::String,oc)
    tag = replace(tag, r"[<>/]" => "")
    if oc == "open"
        tag = split(tag, ' ')[1]
    end
    return tag
end

function tags_match(open_tag::String, close_tag::String)::Bool
    open_name  = tag_to_name(open_name, "open")
    close_name = tag_to_name(close_name, "close")
    return open_name == close_name
end



end
