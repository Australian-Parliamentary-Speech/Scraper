module XML_Scraper
using AndExport 
using EzXML
using utils
using write_utils
using scrape_utils
using Questions
using Scraper
using Interjections
using CSV
using load_set_up

@xport function question_time_main(run_,fn)
    xdoc = readxml("urls/test_files/2023-12-07.xml")
    soup = root(xdoc)
    q_dict,a_dict=question_time_node(soup,run_)
    q_to_a = scrape_question_time_node(q_dict,a_dict,soup,run_)
    fn = "question_to_answers_1.csv"
    open(fn, "w") do io
        write_row_to_io(io,["question_flag","answer_flag","interjection_flag","name","name.id","electorate","party","content"])
        sorted_keys = Question_key_sort(collect(keys(q_to_a)))
        for key in sorted_keys
            """question"""
            question_node = q_to_a[key][1][1]
            @show question_node.path
            answer_nodes = q_to_a[key][2]
            """question"""
            io = rows_construct(soup,"question",question_node,io,run_)
            for answer_node in answer_nodes
                io = rows_construct(soup,"answer",answer_node,io,run_)
            end
        end
    end
end


end

