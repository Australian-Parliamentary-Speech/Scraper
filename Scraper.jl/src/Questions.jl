module Questions
using AndExport
using utils

function create_dict_multiple_values(keys,values)
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

function get_dict(soup,xpath,split_func)
    nodes = find_node(soup,xpath)
    n_ids = [split_func(n.path) for n in nodes]
    n_dict = create_dict_multiple_values(n_ids,nodes)
    return n_dict
end

@xport function question_time(soup)
    function split_func(expr)
        return split(expr,"/")[4:5] 
    end
    """question using question.path for ordering"""
    q_dict = get_dict(soup,"chamber.xscript//question",split_func)
    """answer"""
    a_dict = get_dict(soup,"chamber.xscript//answer",split_func)
    return q_dict, a_dict
end 

@xport function scrape_question_time(q_dict,a_dict)
    q_to_a = Dict()
    for q_id in keys(q_dict)
        try
            q_to_a[q_id] = (q_dict[q_id],a_dict[q_id])
        catch KeyError
            q_to_a[q_id] = (q_dict[q_id],["NA"])
        end
    end
    return q_to_a
end

@xport function answer_to_questions(soup)
    function split_func(expr)
        return split(n.path,"/")
    end
    q_dict = get_dict(soup,"answers.to.questions//question",split_func)
    a_dict = get_dict(soup,"answers.to.questions//answer",split_func)
    return q_dict,a_dict
end


end
