module Interjections
using EzXML
using utils
using scrape_utils
using AndExport
using load_set_up
using Parameters

@xport function get_continue_dict(path,soup,run_)
    @unpack xpaths = run_
    cont_path = "$(path)$(xpaths["CONTINUE"])"
    cont_dict = get_dict(soup,cont_path,Continue_set_key)
    return cont_dict
end

@xport function get_interjections_dict(path,soup,run_)
    @unpack xpaths = run_
    inter_path = "$(path)$(xpaths["INTERJECTION"])"
    inter_dict = get_dict(soup,inter_path,Interject_set_key)
#    inter_nodes = find_in_subsoup(path,soup,xpaths["INTERJECTION"],:all)
#    inter_nodes = findall("$(path)//interjection",soup)
    return inter_dict
end

@xport function get_inter_talk_nodes(inter_node,soup,run_)
    @unpack xpaths = run_
    inter_talk_nodes = find_in_subsoup(inter_node.path,soup,xpaths["TALK_NODE"],:all)
    return inter_talk_nodes
end

@xport function get_inter_talk_content(inter_talk_node,soup,run_)
    @unpack xpaths,talker_option = run_
    inter_talk_content_node = find_in_subsoup(inter_talk_node.path,soup,xpaths["TALK_CONTENT"],:first)
    if inter_talk_content_node == nothing
        if talker_option["GET_ALL_TEXT"] == true
            return filter_(get_all_text_minus_nodes(inter_talk_node,["$(inter_talk_node.path)$(xpaths["TALKER"][2:end])"]))
        else
            return "N/A"
        end
    else
        return filter_(inter_talk_content_node.content)
    end
end

@xport function interjection_edit(inter,run_)
    @unpack general_option = run_ 
    inter_speaker = inter[1]
    inter_content = inter[2]
    if general_option["TALKER_NAME_INTO_CONTENT"] == true
        if occursin("interjecting", inter_speaker[1])
            if inter_content != "N/A"
                inter_content = inter_content*inter_speaker[1]
            else
                inter_content = inter_speaker[1]
            end
            inter_speaker[1] = string(match(r"(.+?)\s+interjecting—", inter_speaker[1]).captures[1])
        end
    end

    return (inter_speaker,inter_content)
end

@xport function sort_all_interjects_nodes(merged_dict,child_to_index,run_)
    all_paths = collect(keys(merged_dict))
    sorted_paths = sort_based_on_order(all_paths,child_to_index)
    sorted_nodes = [merged_dict[path][1] for path in sorted_paths]
    return sorted_nodes
end


@xport function produce_inter_content(node,soup,run_)
    path = node.path
    child_to_index = children_to_indices_dict(node)
    cont_dict = get_continue_dict(path,soup,run_)
    inter_dict = get_interjections_dict(path,soup,run_)
    merged_dict = merge(cont_dict,inter_dict)
    sorted_nodes = sort_all_interjects_nodes(merged_dict,child_to_index,run_)
    inters=[]
    for inter_node in sorted_nodes
        """get all talk nodes in interjections"""
        inter_talk_nodes = get_inter_talk_nodes(inter_node,soup,run_)
        """get all talk contents in interjections"""
        inter_talk_contents = [get_inter_talk_content(i,soup,run_) for i in inter_talk_nodes]

        """get node interjection speakers content"""
        inter_talkers = [get_talker(i.path,soup,run_) for i in inter_talk_nodes]
        push!(inters,collect(zip(inter_talkers,inter_talk_contents)))
    end
    return inters
end


end
