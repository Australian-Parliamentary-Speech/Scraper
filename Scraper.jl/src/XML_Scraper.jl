union!(LOAD_PATH, ["/home/eve/Desktop/Parlinfo_text_project/Scraper.jl/src"])
using EzXML
using utils

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
        q_to_a[q_id] = (q_dict[q_id],a_dict[q_id])
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
    q_dict,a_dict = question_time(soup)
#    q_dict,a_dict = answer_to_questions(soup)
    q_to_a = scrape_question_time(q_dict,a_dict)
    for key in keys(q_to_a)
        @show key
        @show  [filter_(i.content) for i in q_to_a[key]]
    end
    return soup
end


