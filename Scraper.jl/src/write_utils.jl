module write_utils
using AndExport 
using utils
using scrape_utils
using load_set_up
using Parameters
using EzXML

@xport function find_subdebateinfo(soup,node,run_)
    @unpack xpaths = run_
    xpath = xpaths["SUBDEBATE_TITLE"]
    debate_node = parentnode(node)
    subdebatenode = find_in_subsoup(debate_node.path,soup,xpath,:first)
    return subdebatenode.content
end

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


@xport function separate_talk_subdiv_nodes(node,soup,run_,section)
    @unpack general_option,question_option,xpaths = run_
    p_nodes = find_in_subsoup(node.path,soup,xpaths["SUBDIV_1"],:all)
    function find_talker_in_p(p_node)
        p_talker = find_in_subsoup(p_node.path,soup,xpaths["SUBDIV_1_TALKER"],:first)
        if p_talker == nothing
            """if a_asparent shall be different for each section"""
            a_asparent = if section == :question
                question_option["A_ASPARENT"]
            else
                general_option["A_ASPARENT"]
            end

            p_talker = if a_asparent
                p_with_a_as_parent(p_node,soup)
            elseif !a_asparent
                "N/A"
            else
                @assert false "a_asparent not loaded corretly"
            end
        end
       return p_talker
    end
    p_talker_nodes = [find_talker_in_p(p_node) for p_node in p_nodes]
    return p_nodes,p_talker_nodes
end

@xport function separate_talk_subdiv_content(node,soup,run_,section)
    p_nodes,p_talker_nodes = separate_talk_subdiv_nodes(node,soup,run_,section)
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

@xport function p_with_a_as_parent(p_node,soup)
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




end
