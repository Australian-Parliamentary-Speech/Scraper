module Questions
using AndExport
using utils

@xport function question_time(soup)
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

@xport function scrape_question_time(q_dict,a_dict)
    q_to_a = Dict()
    for q_id in keys(q_dict)
        try
            q_to_a[q_id] = (q_dict[q_id],a_dict[q_id])
        catch KeyError
            q_to_a[q_id] = (q_dict[q_id],' ')
        end
    end
    return q_to_a
end

@xport function answer_to_questions(soup)
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


end
