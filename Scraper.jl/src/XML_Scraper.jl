union!(LOAD_PATH, ["/home/eve/Desktop/Parlinfo_text_project/Scraper.jl/src"])
using EzXML
using utils
using Questions
using CSV


function talker_from_qa(path,soup)
    talker_nodes = findall("$(path)//talker",soup)
    @show talker_nodes
    for talker_node in talker_nodes
        talker_name = findfirst("$(talker_node.path)//name",talker_node)
        @show talker_name.content
        @show talker_name.parentnode.path
    end
end

function read_csv_columns(filename::AbstractString, column_indice::Int)
    df = CSV.File(filename) |> DataFrame
    column = df[:, i]
    return column
end

function test()
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

function test2()
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
#
 
end


 


