module Questions
using AndExport
using utils
using scrape_utils
using Parameters
using load_set_up
using EzXML

@xport function question_time_node(soup,run_)
    @unpack section_xpaths,xpaths = run_
    section_paths = section_xpaths["QUESTIONS WITHOUT NOTICE"]
    question_paths = ["$(section_path)$(xpaths["QUESTION"])" for section_path in section_paths]
    answer_paths = ["$(section_path)$(xpaths["ANSWER"])" for section_path in section_paths]
    """question using question.path for ordering"""
    q_dict = get_dict(soup,question_paths,set_key_question_time)
    """answer"""
    a_dict = get_dict(soup,answer_paths,set_key_question_time)
    return q_dict, a_dict
end 

@xport function scrape_question_time_node(q_dict,a_dict,soup,run_)
    @unpack question_option = run_
    q_to_a = Dict()
    for q_id in keys(q_dict)
        if is_question_time(q_dict[q_id][1],run_,soup)
            try
                q_to_a[q_id] = (q_dict[q_id],a_dict[q_id])
            catch KeyError
                q_to_a[q_id] = (q_dict[q_id],["NA"])
            end
        end
    end
    return q_to_a
end

@xport function answer_to_questions_node(soup)
    q_dict = get_dict(soup,"answers.to.questions//question",set_key_answer_to_questions)
    a_dict = get_dict(soup,"answers.to.questions//answer",set_key_answer_to_questions)
    return q_dict,a_dict
end

function p_with_a_as_parent(p_node,soup)
    function parent_path_check(parent_path)
        paths = split(parent_path,"/")
        path_end = paths[end]
        if path_end == 'a' || path_end == "a" || occursin(r"^a\[\d+\]$", path_end)
            return true
        else
            return false
        end
    end
    if parent_path_check(p_node.parentnode.path)
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


@xport function separate_talk_subdiv_nodes(node,soup,run_)
    @unpack question_option,xpaths = run_
    p_nodes = find_in_subsoup(node.path,soup,xpaths["SUBDIV_1"],:all)
    function find_talker_in_p(p_node)
        p_talker = find_in_subsoup(p_node.path,soup,xpaths["SUBDIV_1_TALKER"],:first)
        if p_talker == nothing
            if question_option["A_ASPARENT"] == true
                p_talker = p_with_a_as_parent(p_node,soup)
            else
                p_talker = "N/A"
            end
        end
       return p_talker
    end

    p_talker_nodes = [find_talker_in_p(p_node) for p_node in p_nodes]
    return p_nodes,p_talker_nodes
end

@xport function separate_talk_subdiv_content(node,soup,run_)
    p_nodes,p_talker_nodes = separate_talk_subdiv_nodes(node,soup,run_)
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




end
