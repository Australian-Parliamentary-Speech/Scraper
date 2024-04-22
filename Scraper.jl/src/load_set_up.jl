module load_set_up
using BetterInputFiles
using OrderedCollections 
using ArgParse
using Scraper
using utils
using AndExport

@xport function setup()
    input = setup_input("scrape_set_up.toml", true)
    run_ = Run_Params(input["QUESTION_OPTION"],input["TALKER_OPTION"],input["GENERAL_OPTION"],input["XPATHS"])
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



end

