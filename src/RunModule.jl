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

function get_year(fn)
    xdoc = readxml(fn)
    soup = root(xdoc)
    time_node = findfirst("//session.header/date",soup)
    time = time_node.content
    year = split(time,"-")[1]
    return (parse(Int,year),time)
end

function run_ParlinfoSpeechScraper(toml::Dict{String, Any})
    global_options = toml["GLOBAL"]
    input_path = global_options["INPUT_PATH"]
    output_path = global_options["OUTPUT_PATH"]

    xml_paths = [] 

    # Get single xml path
    single_xmls = get(toml, "XML", [])
    for single_xml in single_xmls
        filename = single_xml["FILENAME"]
        if ! isabspath(filename)
            filename = joinpath(input_path, filename)
        end
        push!(xml_paths, filename)
    end

    # Get all xml paths in a directory
    xml_dirs = get(toml,"XML_DIR",[])
    for xml_dir in xml_dirs
         path = xml_dir["PATH"]
         if ! isabspath(path)
             path = joinpath(input_path,path)
         end
         for filename in readdir(path)
             push!(xml_paths,joinpath(path,filename))
         end
    end

    for fn in xml_paths
        run_xml(fn,output_path)
    end
end

function run_xml(fn,output_path)
    xdoc = readxml(fn)
    soup = root(xdoc)
    year,date = get_year(fn)
    PhaseType = detect_phase(year)
    open(joinpath(output_path,"$date.csv"), "w") do io
        #only line that needs to be updated in terms of change in columns
        write_row_to_io(io,["question_flag","answer_flag","interjection_flag","speech_flag","others_flag","name","name.id","electorate","party","content","subdebateinfo","path"])
        recurse(soup,year,PhaseType,soup,io)
    end
end


function if_defined(node)
    node_name = nodename(node)
    node_symbol = Symbol("$(uppercasefirst(node_name))Node")
    node_struct = getfield(NodeModule,node_struct_symbol)
end

function recurse(soup, year, PhaseType, xml_node, io, index=1,depth=0, max_depth=0, node_tree=Vector{Node}())
    # If max_depth is defined, and depth has surpassed, don't do anything
    if (max_depth > 0) && (depth > max_depth)
        return nothing
    end

    # Debug statements indented by depth
    ins = ' '^depth
    @debug "$(ins)depth: $depth"
    @debug "$(ins)max_depth: $max_depth"
    @debug "$(ins)node_tree has $(length(node_tree)) elements"

    # First parse the current node, if it is parsable

    # First get nodetype of this node
    NodeType = detect_node_type(xml_node, node_tree, year,soup,PhaseType)
    # If NodeType is not nothing, then we can parse this node
    if !isnothing(NodeType)
        @info "NodeType: $NodeType"
        node = Node{NodeType{PhaseType}}(xml_node,index,year, soup)
        parse_node(node, node_tree, io)
    else
        @debug "$(ins)NodeType: GenericNode"
        node = Node{GenericNode{GenericPhase}}(xml_node,index,year,soup)
    end
    # Next, recurse into any subnodes
    subnodes = elements(xml_node)
    @debug"$(ins)num_subnodes: $(length(subnodes))"
    if length(subnodes) > 0
        # Add node to subnode tree
        subnode_tree = copy(node_tree)
        #subnode_tree = node_tree
        #subnode_tree = (node_tree..., node)
        if !(node isa Node{<:GenericNode})
            push!(subnode_tree, node)
        end
        for (i,subnode) in enumerate(subnodes)
            recurse(soup,year,PhaseType,subnode,io,i,depth+1,max_depth,subnode_tree)
        end
    end
end
end
