module load_set_up
using BetterInputFiles
using OrderedCollections 
using ArgParse
using Scraper
using utils
using EzXML
using AndExport

@xport function setup()
    input = setup_input("scrape_set_up.toml", true)
    general_option = input["GENERAL_OPTION"]
    section_xpaths_ = input["SECTION_XPATHS"]
    if general_option["WHICH_CHAMBER"] == "fedchamb"
        section_xpaths = section_xpaths_["FEDCHAMB_SECTION_XPATHS"]
    elseif general_option["WHICH_CHAMBER"] == "chamber"
        section_xpaths = section_xpaths_["CHAMBER_SECTION_XPATHS"]
    end

    run_ = Run_Params(general_option,input["WHICH_SECTIONS"],input["QUESTION_OPTION"],input["TALKER_OPTION"],section_xpaths,input["XPATHS"])
    return run_
end

@xport function set_key_question_time(expr)
    key = collect(split(expr,"/")[4:5])
    key = Question_key_processor(key)
    return key
end

@xport function Question_key_sort(keys)
    sorted_list = sort(keys, by = x -> (x[1], x[2]))
    return sorted_list
end

@xport function set_key_answer_to_questions(expr)
    return collect(split(n.path,"/"))
end

function Question_key_processor(keys)
    key_final = []
    for key in keys
        num = match(r"\[(.*?)\]", key) 
        if num == nothing 
            num = 0
        else
            num = Float_((num.match[2:end-1]))
        end
        push!(key_final,num)
    end
    return key_final
end

@xport function Interject_set_key(keys)
    return keys
end

 @xport function Continue_set_key(keys)
    return keys
end

"""key sort for interjections"""
@xport function children_to_indices_dict(node)
    children_paths = [element.path for element in elements(node)]
    return Dict(zip(children_paths,collect(1:length(children_paths))))
end


end

