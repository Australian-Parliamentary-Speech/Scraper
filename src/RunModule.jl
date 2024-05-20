module RunModule


export run_ParlinfoSpeechScraper

include("Utils.jl")
using .Utils

include("XMLModule.jl")
using .XMLModule

include("NodeModule.jl")
using .NodeModule


struct Run_
    year::Int64
end


function get_time(fn)
    xdoc = readxml(fn)
    soup = root(xdoc)
    time_node = findfirst("//session.header/date",soup)
    time = time_node.content
    return time   
end

function which_toml(time)
    return "xpaths_set_up.toml"
end


function run_ParlinfoSpeechScraper(toml="")
#    for fn in readdir("xml_dir/", join=false)
#        time = get_time(fn)
#        toml_fn = which_toml(time)
    date = "2023-12-07"
    @info date
    xdoc = readxml("xmls/test_files/$date.xml")
    soup = root(xdoc)
    debate_node = findfirst("//debate",soup) 
end

function parse_node(node,node_tree)
    @show nodename(node)
end

function if_defined(node)
    node_name = nodename(node)
    node_symbol = Symbol("$(uppercasefirst(node_name))Node")
    node_struct = getfield(NodeModule,node_struct_symbol)
end

function recurse(scrape_run,node,depth=1,node_tree=[])
    #    @show nodename(node)
    node_tree_names = [nodename(n) for n in node_tree]
    for subnode in elements(node)
        #        NodeType = detect_node_type(node,node_tree,scrape_run.year)
        #        if NodeType != nothing
        #            @info NodeType
        #            node_tree = vcat(node_tree,node)
        #        end
        if nodename(subnode) in  ["p","speech","talk.text"]
            node_tree = vcat(node_tree,nodename(subnode))
        end
        content = recurse(scrape_run,subnode,depth+1,vcat(node_tree,add))
    end
    parse_node(node,node_tree)
end



end
