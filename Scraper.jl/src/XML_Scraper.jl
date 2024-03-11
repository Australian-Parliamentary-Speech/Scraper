union!(LOAD_PATH, ["/home/eve/Desktop/Parlinfo_text_project/Scraper.jl/src"])
using EzXML
using utils
using Questions

#next step: resume ordering by abandoning dicts
function test()
    xdoc = readxml("urls/xml_files/2021-02-03.xml")
    soup = root(xdoc)
    q_dict,a_dict = question_time(soup)
#    q_dict,a_dict = answer_to_questions(soup)
    q_to_a = scrape_question_time(q_dict,a_dict)
    for key in keys(q_to_a)
        @show key
    end
    return soup
end

function test2()
    xdoc = readxml("check.xml")
#    xdoc = readxml("urls/xml_files/2021-02-03.xml")
    soup = root(xdoc)
    inter = find_node(soup,"chamber.xscript//interjection")
    qs = find_node(soup,"chamber.xscript//question")
    as = find_node(soup,"chamber.xscript//answer")

    for q in qs
        @show q.path
    end

    for a in as
        @show a.path
    end

    for i in inter
        @show filter_(i.path)
    end
end


 


