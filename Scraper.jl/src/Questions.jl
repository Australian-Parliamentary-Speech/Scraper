module Questions
using Parameters
using EzXML
using AndExport
using Interjections
using utils
using scrape_utils
using write_utils
using load_set_up

@xport function question_time_node(soup,run_)
    @unpack section_xpaths,xpaths,general_option = run_
    section_paths_ = section_xpaths["QUESTIONS WITHOUT NOTICE"]
    question_paths = ["$(section_path)$(xpaths["QUESTION"])" for section_path in section_paths_]
    answer_paths = ["$(section_path)$(xpaths["ANSWER"])" for section_path in section_paths_]
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
        try
            q_to_a[q_id] = (q_dict[q_id],a_dict[q_id])
        catch KeyError
            q_to_a[q_id] = (q_dict[q_id],["NA"])
        end
    end
    return q_to_a
end

@xport function answer_to_questions_node(soup)
    q_dict = get_dict(soup,"answers.to.questions//question",set_key_answer_to_questions)
    a_dict = get_dict(soup,"answers.to.questions//answer",set_key_answer_to_questions)
    return q_dict,a_dict
end

########write into csv##############

@xport function separate_talk_subdiv_content_question(node,soup,run_)
    return separate_talk_subdiv_content(node,soup,run_,:question)
end


end
