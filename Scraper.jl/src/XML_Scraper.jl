union!(LOAD_PATH, ["/home/eve/Desktop/Parlinfo_text_project/Scraper.jl/src"])
using EzXML
using utils
using Questions

#next step: resume ordering by abandoning dicts
function test()
#    xdoc = readxml("urls/test_files/2023-12-07.xml")
    xdoc = readxml("urls/test_files/check.xml")
    soup = root(xdoc)
    q_dict,a_dict = question_time(soup)
#    q_dict,a_dict = answer_to_questions(soup)
    q_to_a = scrape_question_time(q_dict,a_dict)
    for key in keys(q_to_a)
        @show filter_(q_to_a[key][1].content)
        try
            @show filter_(q_to_a[key][2].content)
        catch
            print("Nothing?")
            @show q_to_a[key][2]
        end
    end
    return soup
end

function talker_from_qa(path,soup)
    talker_nodes = findall("$(path)//talker",soup)
    @show talker_nodes
    for talker_node in talker_nodes
        talker_name = findfirst("$(talker_node.path)//name",talker_node)
        @show talker_name.content
        @show talker_name.parentnode.path
    end
end


function test2()
#    xdoc = readxml("urls/test_files/2023-12-07.xml")
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


 


