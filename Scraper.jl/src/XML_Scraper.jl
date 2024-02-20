union!(LOAD_PATH, ["/home/eve/Desktop/Parlinfo_text_project/Scraper.jl/src"])
using EzXML
using utils


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
    function get_dict(content)
        nodes = find_node(soup,content)
        n_ids = [split(n.path,"/")[4:5] for n in nodes]
        n_dict = Dict(n_ids[i] => nodes[i] for i in 1:length(n_ids))
        return n_dict
    end
    """question using question.path for ordering"""
    q_dict = get_dict("chamber.xscript//question")
    """answer"""
    a_dict = get_dict("chamber.xscript//answer")
    return q_dict, a_dict
end 

function scrape_question_time(q_dict,a_dict)
    q_to_a = Dict()
    for q_id in keys(q_dict)
        q_to_a[q_dict[q_id]] = a_dict[q_id]
    end
    return q_to_a
end

function scrape_q_and_a(q_dict,a_dict)
    q_to_a = Dict()
    for n in 1:length(keys(q_dict)) 
        q_to_a[q_dict[n]] = a_dict[n]
    end
    return q_to_a
end


function answer_to_questions(soup)
    function get_dict(content)
        nodes = find_node(soup,content)
        n_ids = [split(n.path,"/") for n in nodes]
        n_dict =Dict(extract_number(n_ids[i][end]) => nodes[i] for i in 1:length(n_ids))
        return n_dict
    end
    q_dict = get_dict("answers.to.questions//question")
    a_dict = get_dict("answers.to.questions//answer")
    return q_dict,a_dict
end

#next step: resume ordering by abandoning dicts
function test()
    xdoc = readxml("urls/xml_files/2019-04-02.xml")
    soup = root(xdoc)
#    q_dict,a_dict = question_time(soup)
#    q_to_a = scrape_question_time(q_dict,a_dict)
    q_dict,a_dict = answer_to_questions(soup)
    q_to_a = scrape_q_and_a(q_dict,a_dict)
    for key in keys(q_to_a)
        @show filter(key.content)[1:200]
        @show filter(q_to_a[key].content)[1:200]
    end
    return soup
end


