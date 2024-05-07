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

function define_flags(flag)
    if flag == "question"
        flags = [1,0,0]
    elseif flag == "answer"
        flags = [0,1,0]
    elseif flag == "interjection"
        flags = [0,0,1]
    end
    return flags 
end


@xport function question_time_rows_construct(soup,flag,node,io,run_)
    @unpack general_option = run_
    subdebateinfo = find_subdebateinfo(soup,node,run_)

    flags = define_flags(flag)
    """get node speaker content"""
    talker = get_talker(node.path,soup,run_)

    if general_option["SEP_BY_SUBDIV_1"] == true
        question_row_construct_p_content(node,soup,io,flags,talker,run_,subdebateinfo)
    else
        node_row = [flags...,talker...,filter_(node.content),subdebateinfo,node.path]
        write_row_to_io(io,node_row)
    end

    """inter"""   
    if general_option["INTER_UNDER_NODE"] == true
        inters = produce_inter_content(node,soup,run_)
        for inter in inters
            for inter_talk in inter
                inter_speaker, inter_content = interjection_edit(inter_talk,run_)
                inter_row = [0,0,1,inter_speaker...,inter_content,subdebateinfo,node.path]
                write_row_to_io(io,inter_row)
            end
        end
    end
    return io
end

function separate_talk_subdiv_content_question(node,soup,run_)
    return separate_talk_subdiv_content(node,soup,run_,:question)
end


function question_row_construct_p_content(node,soup,io,flags,talker,run_,subdebateinfo)
#    talker[1] = remove_the_speaker(talker[1])
    path_for_debug = node.path

    """separate text into blocks of p"""
    p_talker_content = separate_talk_subdiv_content_question(node,soup,run_)

    """write first row first"""
    node_row = [flags...,talker...,p_talker_content[1][2],subdebateinfo,path_for_debug]
    write_row_to_io(io,node_row)
  
    for i in 2:length(p_talker_content)
        p_talker,p_content = p_talker_content[i]
        write_row_to_io(io,[0,0,0,p_talker,"N/A","N/A","N/A",p_content,subdebateinfo,path_for_debug])
    end
end

end
