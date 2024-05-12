union!(LOAD_PATH, ["/home/eve/Desktop/Parlinfo_text_project/Scraper.jl/src"])
using EzXML
using CSV
using Parameters
using utils
using write_utils
using scrape_utils
using Questions
using Scraper
using Interjections
using Speeches
using write_to_file_shared
using load_set_up

function test_speeches()
    run_ = setup()
    @unpack section_xpaths = run_
    xdoc = readxml("urls/test_files/2023-12-07.xml")
    soup = root(xdoc)
    fn = "speeches.csv"
    open(fn, "w") do io
        write_row_to_io(io,["question_flag","answer_flag","interjection_flag","speech_flag","others_flag","name","name.id","electorate","party","content","subdebateinfo","path"])
        debate_keys = get_all_speech_debate_keys_ordered(run_)
        for debate_key in debate_keys
            debate_paths = section_xpaths[debate_key]
            for debate_path in debate_paths
                subdebate_nodes = get_speech_subdebate_nodes(debate_path,soup,run_)
                for subdebate_node in subdebate_nodes
                    speech_nodes,other_nodes = get_wanted_nodes(subdebate_node,soup,run_)
                    all_nodes = vcat(speech_nodes,other_nodes)
                    for node in all_nodes
                        io = rows_construct(soup,:speech,node,io,run_,separate_talk_subdiv_content_speech)
                    end
                end
            end
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
        write_row_to_io(io,["question_flag","answer_flag","interjection_flag","speech_flag","others_flag","name","name.id","electorate","party","content","subdebateinfo","path"])
        sorted_keys = Question_key_sort(collect(keys(q_to_a)))
        for key in sorted_keys
            """question"""
            question_node = q_to_a[key][1][1]
            @show question_node.path
            answer_nodes = q_to_a[key][2]
            """question"""
            io = rows_construct(soup,:question,question_node,io,run_,separate_talk_subdiv_content_question)
            for answer_node in answer_nodes
                io = rows_construct(soup,:answer,answer_node,io,run_,separate_talk_subdiv_content_question)
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


 


