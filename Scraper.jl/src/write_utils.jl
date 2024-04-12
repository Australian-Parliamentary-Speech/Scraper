module write_utils
using AndExport 
using utils
using Interjections
using Questions
using load_set_up

@xport function replace_empty_string(row)
    return map(x -> isempty(x) ? "N/A" : x, row)
end

@xport function write_row_to_io(io,row)
    row = replace_empty_string(row)
    edit_row_ = edit_row(row)
#    if row[4] == "Mr Wallace"
#        @show row
#        @show edit_row_
#    end
    println(io,edit_row_)
end

function row_construct_p_content(node,soup,io,flags,talker,run_)
    talker[1] = remove_the_speaker(talker[1])
    path_for_debug = node.path

    """separate text into blocks of p"""
    p_talker_content = separate_talk_p_content(node,soup,run_)

    """write q/a row first"""
    node_row = [flags...,talker...,p_talker_content[1][2],path_for_debug]
    write_row_to_io(io,node_row)
  
    for i in 2:length(p_talker_content)
        p_talker,p_content = p_talker_content[i]
        write_row_to_io(io,[0,0,0,p_talker,"N/A","N/A","N/A",p_content,path_for_debug])
    end
end


@xport function rows_construct(soup,flag,node,io,run_)
    if flag == "question"
        flags = [1,0,0]
    elseif flag == "answer"
        flags = [0,1,0]
    elseif flag == "interjection"
        flags = [0,0,1]
    end
    talker,inter_to_content = produce_q_a_content(node,soup,run_)
    row_construct_p_content(node,soup,io,flags,talker,run_)

   """inter"""            
    for inter in inter_to_content
        inter_speaker, inter_content = interjection_edit(inter,run_)
        inter_row = [0,0,1,inter_speaker...,inter_content,node.path]
        write_row_to_io(io,inter_row)
    end
    return io
end

#@xport function write_row(question_flag,answer_flag,interjection_flag,content,talker_content)
#    name,name.id,electorate,party = talker_content
#    return [question_flag,answer_flag,interjection_flag,name,name.id,electorate,party,content]
#end

@xport function produce_q_a_content(node,soup,run_)
#    """get node content"""
#    content = find_q_a_talk_text(node,soup)
    path = node.path

    """get node speaker content"""
    talker = get_talker(path,soup)

    """get node interjection content"""
    inter_nodes = get_interjections(path,soup)
    inter_contents = [get_interjection_content(i,soup) for i in inter_nodes]

    """get node interjection speakers content"""
    inter_talkers = [get_talker(i.path,soup) for i in inter_nodes]
    """assumption: there is only one speaker for each question or anser"""
    return talker,collect(zip(inter_talkers,inter_contents))
end


end
