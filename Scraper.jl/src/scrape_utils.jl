module scrape_utils
using AndExport 
using Scraper
using Parameters
using EzXML
using utils


@xport function is_question_time(node,run_,soup)
    @unpack question_option,xpaths = run_
    if question_option["QUESTIONS_WITHOUT_NOTICE"] == true
        debate_node = parentnode(parentnode(node))
        xpath = xpaths["DEBATE_TITLE"]
        title_node = find_in_subsoup(debate_node.path,soup,xpath,:first)
        if title_node.content == "QUESTIONS WITHOUT NOTICE"
            return true
        else
            return false
        end
    else
        return true
    end
end

@xport function get_talker(path,soup,run_)
    talker_node = talker_from_any(path,soup,run_)
    return talker_content(talker_node)
end

@xport function talker_from_any(path,soup,run_)
    @unpack xpaths = run_
    talker_node = findfirst("$(path)$(xpaths["TALKER"])",soup)
    return talker_node
end

@xport function talker_content(talker_node)
    function find_content(xpath)
        talker_content_node = findfirst("$(talker_node.path)//$(xpath)",talker_node)
        #        @show talker_content_node.path
        talker_content = talker_content_node.content
        return talker_content
    end

    talker_contents = []
    for xpath in ["name","name.id","electorate","party"]
        talker_content = find_content(xpath)
        if xpath == "name"
#            @show talker_node.path
#            @show talker_content
        end
        push!(talker_contents,talker_content)
    end
    #        @show talker_name.parentnode.path
    return talker_contents
end



end
