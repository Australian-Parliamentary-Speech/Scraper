module Questions
using AndExport
using utils
using Parameters

function get_dict(soup,xpath,split_func)
    nodes = find_node(soup,xpath)
    n_ids = [split_func(n.path) for n in nodes]
    n_dict = create_dict_multiple_values(n_ids,nodes)
    return n_dict
end

@xport function question_time_node(soup)
    function split_func(expr)
        key = collect(split(expr,"/")[4:5])
        key = Question_key_processor(key)
        return key
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
        return collect(split(n.path,"/"))
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

function p_with_a_as_parent(p_node,soup)
    if p_node.parentnode.path[end] == 'a'
        p_talkers  = find_in_subsoup(p_node.parentnode.path,soup,"/@type",:first)
        if p_talkers != nothing
            return  p_talkers.content
        else
            return "N/A"
        end
    else
        return "N/A"
    end
end


@xport function separate_talk_p_nodes(node,soup,run_)
    @unpack p_option = run_
    p_nodes = find_in_subsoup(node.path,soup,"//p",:all)
    function find_talker_in_p(p_node)
        p_talker = find_in_subsoup(p_node.path,soup,"//a",:first)
        if p_talker == nothing
            if p_option["a_asparent"] == true
                p_talker = p_with_a_as_parent(p_node,soup)
            else
                p_talker = "N/A"
            end
        end
       return p_talker
    end
    p_talker_nodes = []
    for p_node in p_nodes
        p_talker_node = find_talker_in_p(p_node)
        push!(p_talker_nodes,p_talker_node)
    end
    return p_nodes,p_talker_nodes
end

@xport function separate_talk_p_content(node,soup,run_)
    p_nodes,p_talker_nodes = separate_talk_p_nodes(node,soup,run_)
    p_talkers = []
    for t in p_talker_nodes
        if typeof(t) == String
            push!(p_talkers,t)
        else
            push!(p_talkers, filter_(t.content))
        end
    end
    p_talker_contents = [filter_(c.content) for c in p_nodes]
    return collect(zip(p_talkers, p_talker_contents))
end

function Question_key_processor(keys)
    key_final = []
    for key in keys
        num = match(r"\[(.*?)\]", key) 
        if num == nothing 
            num = 0
        else
            num = Float_((num.match[2:end-1]))
        end
        push!(key_final,num)
    end
    return key_final
end

@xport function Question_key_sort(keys)
    sorted_list = sort(keys, by = x -> (x[1], x[2]))
    return sorted_list
end





end
