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

include("EditModule.jl")
using .EditModule



function get_date(fn)
    xdoc = readxml(fn)
    soup = root(xdoc)
    time_node = findfirst("//session.header/date",soup)
    time = time_node.content
    year,month,day = split(time,"-")
    #turns dates into a float for comparison
    return date_to_float(parse(Int,year),parse(Int,month),parse(Int,day)),time
end

function run_ParlinfoSpeechScraper(toml::Dict{String, Any})
    global_options = toml["GLOBAL"]
    general_options = toml["GENERAL_OPTIONS"]
    input_path = global_options["INPUT_PATH"]
    output_path = global_options["OUTPUT_PATH"]
    year_ = general_options["YEAR"]
    if typeof(year_) <: Int
        output_path = joinpath(output_path,"$year_/")
        create_dir(output_path)
    end

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

    # Get all xml paths in a directory with years being the subdirectory
    xml_dirs = get(toml,"XML_DIR",[])
    for xml_dir in xml_dirs
         path = xml_dir["PATH"]
         if ! isabspath(path)
             path = joinpath(input_path,path)
         end
         for year in readdir(path)
             if parse(Int,year) == year_
                for filename in readdir(joinpath(path,year))
                    push!(xml_paths,joinpath(joinpath(path,year),filename))
                end
            end
         end
    end
    csv_exist = toml["GENERAL_OPTIONS"]["CSV_EXIST"]
    edit_opt = toml["GENERAL_OPTIONS"]["EDIT"]
    for fn in xml_paths
        run_xml(fn,output_path,csv_exist,edit_opt)
    end
end

function run_xml(fn,output_path,csv_exist,edit_opt)
    xdoc = readxml(fn)
    soup = root(xdoc)
    date_float,date = get_date(fn)
    PhaseType = detect_phase(date_float)
    outputcsv = joinpath(output_path,"$date.csv")
    if !(csv_exist) 
        open(outputcsv, "w") do io
            headers = ["question_flag","answer_flag","interjection_flag","speech_flag","chamber_flag","name","name.id","electorate","party","role","page.no","content","subdebateinfo","debateinfo","path"]
            write_row_to_io(io,headers)
            recurse(soup,date_float,PhaseType,soup,io)
        end
    end
    ###Edit
    if edit_opt
        edit_csv(outputcsv,PhaseType)
    end
end


function recurse(soup, date, PhaseType, xml_node, io, index=1,depth=0, max_depth=0, node_tree=Vector{Node}())
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
    NodeType = detect_node_type(xml_node, node_tree, date,soup,PhaseType)
    # If NodeType is not nothing, then we can parse this node
    if !isnothing(NodeType)
        node = Node{NodeType{PhaseType}}(xml_node,index,date,soup)
        @debug "NodeType: $(typeof(node))"
        parse_node(node, node_tree, io)
    else
        @debug "$(ins)NodeType: GenericNode"
        node = Node{GenericNode{GenericPhase}}(xml_node,index,date,soup)
    end

    # Next, recurse into any subnodes
    subnodes = elements(xml_node)
    @debug"$(ins)num_subnodes: $(length(subnodes))"
    #       @show node_tree
    if length(subnodes) > 0
        # Add node to subnode tree
        subnode_tree = copy(node_tree)
        #subnode_tree = node_tree
        #subnode_tree = (node_tree..., node)
        if !(node isa Node{<:GenericNode})
            push!(subnode_tree, node)
        end
        for (i,subnode) in enumerate(subnodes)
            recurse(soup,date,PhaseType,subnode,io,i,depth+1,max_depth,subnode_tree)
        end
    end
end
end
