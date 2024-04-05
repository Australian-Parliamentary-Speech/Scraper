module write_utils
using AndExport 
using utils
using Interjections
using Questions

@xport function write_row_to_io(io,row)
    edit_row_ = edit_row(row)
    println(io,edit_row_)
end

function row_construct_p_content(node,soup,io,flags,talker)
    """separate text into blocks of p"""
    p_talker_content = separate_talk_p_content(node,soup)
    talker[1] = remove_the_speaker(talker[1])

    """write q/a row first"""
    node_row = [flags...,talker...,p_talker_content[1][2]]
    write_row_to_io(io,node_row)
  
    for i in 2:length(p_talker_content)
        p_talker,p_content = p_talker_content[i]
        if occursin("SPEAKER",p_talker)
            p_talker = talker
            node_row = [0,0,0,talker...,p_content]
            write_row_to_io(io,node_row)
        else 
            write_row_to_io(io,[0,0,0,p_talker,"N/A","N/A","N/A",p_content])
        end
    end
end


@xport function rows_construct(soup,flag,node,io)
    if flag == "question"
        flags = [1,0,0]
    elseif flag == "answer"
        flags = [0,1,0]
    elseif flag == "interjection"
        flags = [0,0,1]
    end
    talker,inter_to_content = produce_q_a_content(node,soup)
    row_construct_p_content(node,soup,io,flags,talker)

   """inter"""            
    for inter in inter_to_content
        inter_speaker = inter[1]
        inter_content = inter[2]
        inter_row = [0,0,1,interjector_name(inter_speaker[1]),inter_speaker[2:end]...,inter_content]
        write_row_to_io(io,inter_row)
    end
    return io
end

#@xport function write_row(question_flag,answer_flag,interjection_flag,content,talker_content)
#    name,name.id,electorate,party = talker_content
#    return [question_flag,answer_flag,interjection_flag,name,name.id,electorate,party,content]
#end

@xport function produce_q_a_content(node,soup)
#    """get node content"""
#    content = find_q_a_talk_text(node,soup)
    path = node.path

    """get node speaker content"""
    talker = get_talker(path,soup)

    """get node interjection content"""
    inter_nodes = get_interjections(path,soup)
    inter_contents = [filter_(i.content) for i in inter_nodes]

    """get node interjection speakers content"""
    inter_talkers = [get_talker(i.path,soup) for i in inter_nodes]
    """assumption: there is only one speaker for each question or anser"""
    return talker,collect(zip(inter_talkers,inter_contents))
end


end
