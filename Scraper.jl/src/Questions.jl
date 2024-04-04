module Questions
using AndExport
using utils

function get_dict(soup,xpath,split_func)
    nodes = find_node(soup,xpath)
    n_ids = [split_func(n.path) for n in nodes]
    n_dict = create_dict_multiple_values(n_ids,nodes)
    return n_dict
end

@xport function question_time_node(soup)
    function split_func(expr)
        return split(expr,"/")[4:5] 
    end
    """question using question.path for ordering"""
    q_dict = get_dict(soup,"chamber.xscript//question",split_func)
    """answer"""
    a_dict = get_dict(soup,"chamber.xscript//answer",split_func)
    return q_dict, a_dict
end 

@xport function scrape_question_time_node(q_dict,a_dict)
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

@xport function answer_to_questions_node(soup)
    function split_func(expr)
        return split(n.path,"/")
    end
    q_dict = get_dict(soup,"answers.to.questions//question",split_func)
    a_dict = get_dict(soup,"answers.to.questions//answer",split_func)
    return q_dict,a_dict
end

@xport function find_q_a_talk_text(node,soup)
    text_node = find_in_subsoup(node.path,soup,"/talk.text",:first)
#    path = node.path
#    text_node = findfirst("$(path)/talk.text",soup)
    return filter_(text_node.content)
end

@xport function separate_talk_p_nodes(node,soup)
    p_nodes = find_in_subsoup(node.path,soup,"//p",:all)
    function find_talker_in_p(p_node)
        p_talker = find_in_subsoup(p_node.path,soup,"//a",:first)
        return p_talker
    end
    p_talk_nodes = []
    for p_node in p_nodes
        p_talk_node = find_talker_in_p(p_node)
        push!(p_talk_nodes,p_talk_node)
    end
    return p_nodes,p_talk_nodes
end

@xport function separate_talk_p_content(node,soup)
    p_nodes,p_talk_nodes = separate_talk_p_nodes(node,soup)
    return [p_node.content for p_node in p_nodes],[p_talk_node.content for p_talk_node in p_talk_nodes]
end


end
