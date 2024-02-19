using EzXML

function find_text(soup,content,delim=nothing)
    text_list = nodecontent.(findall("$content", soup))
    if split != nothing
        text_new_list = []
        for text in text_list
            push!(text_new_list,split(text,delim))
        end
    end
    return [filter(t) for t in text_list]        
end

function find_node(soup,nodename)
    nodes = []
    for node in findall("$nodename", soup)
        push!(nodes,node)
    end    
    return nodes
end

function filter(str::AbstractString)
    # Replace newline characters with an empty string
    filtered_str = replace(str, "\n" => "")
    # Replace multiple spaces with a single space, excluding spaces between words
    filtered_str = replace(filtered_str, r"\s+" => " ")
    return filtered_str
end

function question_time(soup)
    function get_dict(q_or_a)
        content = "chamber.xscript//$q_or_a"
        nodes = find_node(soup,content)
        n_ids = [split(n.path,"/")[4:5] for n in nodes]
        n_dict = Dict(n_ids[i] => nodes[i] for i in 1:length(n_ids))
        return n_dict
    end
    """question.path"""
    q_dict = get_dict("question")
    """answer"""
    a_dict = get_dict("answer")
    return q_dict, a_dict
end 

function test()
    xdoc = readxml("urls/xml_files/2019-04-02.xml")
    soup = root(xdoc)
    q_dict,a_dict = question_time(soup)
    for qid in keys(q_dict)
        @show q_dict[qid].path
#        @show filter(q_dict[qid].content)
#        @show filter(a_dict[qid].content)
    end
    return soup
end


