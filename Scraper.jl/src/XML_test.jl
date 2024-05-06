union!(LOAD_PATH, ["/home/eve/Desktop/Parlinfo_text_project/Scraper.jl/src"])
using EzXML
using utils
using write_utils
using scrape_utils
using Questions
using Scraper
using Interjections
using Speeches
using CSV
using load_set_up
using Parameters

function test_speeches()
    run_ = setup()
    @unpack section_xpaths = run_
    xdoc = readxml("urls/test_files/2023-12-07.xml")
    soup = root(xdoc)
    debate_keys = get_all_speech_debate_keys(run_)
    for debate_key in debate_keys[1:6]
        debate_paths = section_xpaths[debate_key]
        for debate_path in debate_paths
            get_speech_subdebate_nodes(debate_path,soup,run_)
        end
    end
end


function test_one_page_question_time()
#    run_ = Run_Struct(Dict("a_asparent" => true),Dict("question_path" => "question"))
    run_ = setup()
    xdoc = readxml("urls/test_files/2023-12-07.xml")
    soup = root(xdoc)
    q_dict,a_dict=question_time_node(soup,run_)
    q_to_a = scrape_question_time_node(q_dict,a_dict,soup,run_)
    fn = "question_to_answers_1.csv"
    open(fn, "w") do io
        write_row_to_io(io,["question_flag","answer_flag","interjection_flag","name","name.id","electorate","party","content","subdebateinfo","path"])
        sorted_keys = Question_key_sort(collect(keys(q_to_a)))
        for key in sorted_keys
            """question"""
            question_node = q_to_a[key][1][1]
            @show question_node.path
            answer_nodes = q_to_a[key][2]
            """question"""
            io = question_time_rows_construct(soup,"question",question_node,io,run_)
            for answer_node in answer_nodes
                io = question_time_rows_construct(soup,"answer",answer_node,io,run_)
            end
        end
    end
end

function test_interjection()
    xdoc = readxml("urls/test_files/2023-12-07.xml")
    soup = root(xdoc)
    q_dict,a_dict=question_time(soup)
    for value in collect(values(a_dict))[1:2]
        for node in value
            node_path = node.path
            inter_nodes = get_interjections(node_path,soup)
            for inter_node in inter_nodes
#                @show filter_(inter_node.content)
                inter_node_path = inter_node.path
                @show inter_node_path
                talker_nodes = talker_from_any(inter_node_path,soup)
                talkers_contents = talker_content(talker_nodes)
                @show talkers_contents
            end
        end
    end
end


function test_matching()
    xdoc = readxml("urls/test_files/check.xml")
    soup = root(xdoc)
#    inter = find_node(soup,"chamber.xscript//interjection")
    qs = find_node(soup,"chamber.xscript//question")
    as = find_node(soup,"chamber.xscript//answer")
    q_dict,a_dict = question_time(soup)
    q_to_a = scrape_question_time(q_dict,a_dict)
    key = ["debate[14]", "subdebate.1[13]"]
    @show q_to_a[key][1][1].path
    @show [i.path for i in q_to_a[key][2]]
end


 


