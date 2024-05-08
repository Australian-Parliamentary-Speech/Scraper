module write_to_file_shared
using Parameters
using AndExport
using EzXML
using write_utils
using scrape_utils
using Interjections


@xport function define_flags(flag)
    if flag == :question
        flags = [1,0,0,0,0]
    elseif flag == :answer
        flags = [0,1,0,0,0]
    elseif flag == :interjection
        flags = [0,0,1,0,0]
    elseif flag == :speech
        flags = [0,0,0,1,0]
    elseif flag == :non_speech
        flags = [0,0,0,0,1]
    else
        flags = [0,0,0,0,0]
    end
    return flags 
end

@xport function rows_construct(soup,flag,node,io,run_,separate_talk_subdiv_content_function)
    @unpack general_option = run_
    subdebateinfo = find_subdebateinfo(soup,node,run_)
    flags = define_flags(flag)
    """get node speaker content"""
    talker = get_talker(node.path,soup,run_)

    if general_option["SEP_BY_SUBDIV_1"] == true
        row_construct_p_content(node,soup,io,flags,talker,run_,subdebateinfo,separate_talk_subdiv_content_function)
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
                inter_flags = define_flags(:interjection)
                inter_row = [inter_flags...,inter_speaker...,inter_content,subdebateinfo,node.path]
                write_row_to_io(io,inter_row)
            end
        end
    end
    return io
end


function row_construct_p_content(node,soup,io,flags,talker,run_,subdebateinfo,separate_talk_subdiv_content_function)
#    talker[1] = remove_the_speaker(talker[1])
    path_for_debug = node.path

    """separate text into blocks of p"""
    p_talker_content = separate_talk_subdiv_content_function(node,soup,run_)

    """write first row first"""
    node_row = [flags...,talker...,p_talker_content[1][2],subdebateinfo,path_for_debug]
    write_row_to_io(io,node_row)
  
    for i in 2:length(p_talker_content)
        p_talker,p_content = p_talker_content[i]
        flags = define_flags("nothing")
        write_row_to_io(io,[flags...,p_talker,"N/A","N/A","N/A",p_content,subdebateinfo,path_for_debug])
    end
end

end
