module RunModule
using InteractiveUtils
using Reexport

export run_ParlinfoSpeechScraper
export get_year

include("Utils.jl")
using .Utils

include("XMLModule.jl")
using .XMLModule

include("NodeModule.jl")
@reexport using .NodeModule

struct Run_
    year::Int64
end


function get_year(fn)
    xdoc = readxml(fn)
    soup = root(xdoc)
    time_node = findfirst("//session.header/date",soup)
    time = time_node.content
    year = split(time,"-")[1]
    return (parse(Int,year),time)
end

function which_toml(time)
    return "xpaths_set_up.toml"
end


function run_ParlinfoSpeechScraper(fn;toml="")
#    for fn in readdir("xml_dir/", join=false)
#        time = get_time(fn)
#        toml_fn = which_toml(time)
    xdoc = readxml(fn)
    soup = root(xdoc)
    year,date = get_year(fn)
    scrape_run = Run_(year) 
    open("$date.csv", "w") do io
        #only line that needs to be updated in terms of change in columns
        write_row_to_io(io,["question_flag","answer_flag","interjection_flag","speech_flag","others_flag","name","name.id","electorate","party","content","subdebateinfo","path"])
        recurse(soup,scrape_run,soup,io,7)
    end
end


function if_defined(node)
    node_name = nodename(node)
    node_symbol = Symbol("$(uppercasefirst(node_name))Node")
    node_struct = getfield(NodeModule,node_struct_symbol)
end


function recurse(soup,scrape_run,node,io,depth,node_tree=[])
    #    @show nodename(node)
    if depth == 0
        return nothing
    end

    for subnode in elements(node)
        NodeType = detect_node_type(subnode,node_tree,scrape_run.year,soup)
        if NodeType != nothing
            subnode_ = Node{NodeType}(subnode)
            @info NodeType
            node_tree = push!(node_tree,subnode_)
            parse_node(subnode_,node_tree,scrape_run.year,soup,io)
        end
        recurse(soup,scrape_run,subnode,io,depth-1,node_tree)
    end
end



end
