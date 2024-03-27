module write_utils
using AndExport 
using utils
using Interjections

@xport function rows_construct(soup,flag,node,io)
    if flag == "question"
        flags = [1,0,0]
    elseif flag == "answer"
        flags = [0,1,0]
    elseif flag == "interjection"
        flag = [0,0,1]
    end
    speaker_to_content,inter_to_content = produce_q_a_content(node,soup)
    node_row = [flags...,speaker_to_content[1]...,speaker_to_content[2]]
    edit_node_row = edit_row(node_row)
    println(io,edit_node_row)
    """inter"""            
    for inter in inter_to_content
        inter_speaker = inter[1]
        inter_content = inter[2]
        inter_row = [0,0,1,inter_speaker...,inter_content]
        edit_inter_row = edit_row(inter_row)
        println(io,edit_inter_row)
    end
    return io
end

@xport function write_row(question_flag,answer_flag,interjection_flag,content,talker_content)
    name,name.id,electorate,party = talker_content
    return [name,name.id,electorate,party,content,question_flag,answer_flag,interjection_flag]
end

@xport function produce_q_a_content(node,soup)
    """get node content"""
    content = filter_(node.content)
    path = node.path

    """get node speaker content"""
    talker = get_talker(path,soup)

    """get node interjection content"""
    inter_nodes = get_interjections(path,soup)
    inter_contents = [filter_(i.content) for i in inter_nodes]

    """get node interjection speakers content"""
    inter_talkers = [get_talker(i.path,soup) for i in inter_nodes]
    """assumption: there is only one speaker for each question or anser"""
    return (talker,content),collect(zip(inter_talkers,inter_contents))
end


end
