union!(LOAD_PATH, ["/home/eve/Desktop/Parlinfo_text_project/Scraper.jl/src"])
using EzXML
using utils
using write_utils
using Questions
using Interjections
using CSV

function test_one_page()
    xdoc = readxml("urls/test_files/2023-12-07.xml")
    soup = root(xdoc)
    q_dict,a_dict=question_time_node(soup)
    q_to_a = scrape_question_time_node(q_dict,a_dict)
    fn = "question_to_answers_1.csv"
    open(fn, "w") do io
        write_row_to_io(io,["question_flag","answer_flag","interjection_flag","name","name.id","electorate","party","content"])

        for key in keys(q_to_a)
            """question"""
            question_node = q_to_a[key][1][1]
            answer_nodes = q_to_a[key][2]
            """question"""
            io = rows_construct(soup,"question",question_node,io)
            for answer_node in answer_nodes
                io = rows_construct(soup,"answer",answer_node,io)
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


function test_question_time()
    xdoc = readxml("urls/test_files/2023-12-07.xml")
    soup = root(xdoc)
    q_dict,a_dict=question_time(soup)
    q_to_a = scrape_question_time(q_dict,a_dict)
    fn = "question_to_answers_.csv"
    open(fn, "w") do io
        for key in keys(q_to_a)
            question = filter_(q_to_a[key][1][1].content)[1:100]
            answers = [filter_(i.content)[1:100] for i in q_to_a[key][2]]
            row = [question, answers...]
            edit_row = ' '
            for i in row
                edit_row = edit_row * "\"$i\","
            end
            @show edit_row
            println(io,edit_row)
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


 


