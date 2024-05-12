union!(LOAD_PATH, ["/home/eve/Desktop/Parlinfo_text_project/Scraper.jl/src"])
using EzXML
using utils
using TOML

"""which_chamber: chamber or fedchamb"""
function gather_topics(soup,which_chamber)
    debate_nodes = findall("$(which_chamber).xscript/debate",soup)
    debate_title = "/debateinfo/title"
    titles = []
    debate_paths = []
    for debate_node in debate_nodes
        @show debate_node.path
        title_node = find_in_subsoup(debate_node.path,soup,debate_title,:first)
        push!(titles,title_node.content)
        push!(debate_paths,debate_node.path)
    end
    title_to_paths = create_dict_multiple_values(titles,debate_paths)
    return title_to_paths
end

function xpaths_run()
    date = "2023-12-07"
    xdoc = readxml("urls/test_files/2023-12-07.xml")
    soup = root(xdoc)
    for which_chamber in ["chamber","fedchamb"]
        title_to_paths = gather_topics(soup,which_chamber)
        open("$(which_chamber)_section_titles.toml", "w") do io
            TOML.print(io, title_to_paths)
        end
    end
end




