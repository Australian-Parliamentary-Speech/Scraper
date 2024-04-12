module write_utils
using AndExport 
using utils
using Interjections
using Questions
using load_set_up
using Parameters

@xport function edit_row(row)
    edit_row = ""
    for i in row
        i = replace(string(i), "\"" => "\'")
        edit_row = edit_row * "\"$i\","
    end
    return edit_row[1:end-1]
end

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
#    talker[1] = remove_the_speaker(talker[1])
    path_for_debug = node.path

    """separate text into blocks of p"""
    p_talker_content = separate_talk_subdiv_content(node,soup,run_)

    """write q/a row first"""
    node_row = [flags...,talker...,p_talker_content[1][2],path_for_debug]
    write_row_to_io(io,node_row)
  
    for i in 2:length(p_talker_content)
        p_talker,p_content = p_talker_content[i]
        write_row_to_io(io,[0,0,0,p_talker,"N/A","N/A","N/A",p_content,path_for_debug])
    end
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

@xport function rows_construct(soup,flag,node,io,run_)
    @unpack general_option = run_
    flags = define_flags(flag)
    """get node speaker content"""
    talker = get_talker(node.path,soup,run_)

    if general_option["SEP_BY_SUBDIV_1"] == true
        row_construct_p_content(node,soup,io,flags,talker,run_)
    else
        node_row = [flags...,talker...,filter_(node.content),node.path]
        write_row_to_io(io,node_row)
    end

    """inter"""   
    if general_option["INTER_UNDER_NODE"] == true
        inter_to_content = produce_inter_content(node,soup,run_)
        for inter in inter_to_content
            inter_speaker, inter_content = interjection_edit(inter,run_)
            inter_row = [0,0,1,inter_speaker...,inter_content,node.path]
            write_row_to_io(io,inter_row)
        end
    end
    return io
end

#@xport function write_row(question_flag,answer_flag,interjection_flag,content,talker_content)
#    name,name.id,electorate,party = talker_content
#    return [question_flag,answer_flag,interjection_flag,name,name.id,electorate,party,content]
#end

function produce_inter_content(node,soup,run_)
    path = node.path

    """get node interjection content"""
    inter_nodes = get_interjections(path,soup,run_)
    inter_contents = [get_interjection_content(i,soup,run_) for i in inter_nodes]

    """get node interjection speakers content"""
    inter_talkers = [get_talker(i.path,soup,run_) for i in inter_nodes]
    """assumption: there is only one speaker for each question or anser"""
    return collect(zip(inter_talkers,inter_contents))
end


end
