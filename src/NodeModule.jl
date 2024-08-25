#using Reexport
#@reexport module 

module NodeModule
using InteractiveUtils
using EzXML
using ..XMLModule
using ..Utils

export detect_node_type
export Node
export GenericNode
export parse_node
export detect_phase
export GenericPhase
export AbstractPhase
export define_headers

abstract type AbstractPhase end

abstract type GenericPhase <: AbstractPhase end

abstract type AbstractNode{P <: AbstractPhase} end

abstract type GenericNode{P} <: AbstractNode{P} end

struct Node{N <: AbstractNode}
    node::EzXML.Node
    index::Int64
    date::Float64
    soup
end
get_nodetype(::Node{N}) where {N} = N
get_phasetype(::Node{N}) where {P <: AbstractPhase, N <: AbstractNode{P}} = P

#Get Default Nodes
const node_path = joinpath(@__DIR__, "nodes")
for path in readdir(node_path, join=true)
    if isfile(path)
        include(path)
    end
end

# Included phases can add to this dictionary
date_to_phase = Dict()

# Included phases can add to this dictionary
range_to_phase = Dict()

# Get Phase Overwrites
const phase_path = joinpath(node_path, "Phases")
for dir in readdir(phase_path, join=true)
    for path in readdir(dir, join=true)
        if isfile(path)
            include(path)
        end
    end
end

function define_headers(::Type{<:AbstractPhase})
    return ["question_flag","answer_flag","interjection_flag","speech_flag","chamber_flag","name","name.id","electorate","party","role","page.no","content","subdebateinfo","debateinfo","path"]
end

"""
detect_phase(date)

Inputs:
- `date`: A floating-point number representing the date to detect the phase for.

Returns:
- The phase associated with the provided `date`, or `AbstractPhase` if no specific phase is found.
"""
function detect_phase(date)
    # See if year has specific phase
    phase = get(date_to_phase, date, nothing)
    if ! isnothing(phase)
        return phase
    end

    # See if date in range with phase
    for (date_range,phase) in date_to_phase
        min_date, max_date = date_range
        if min_date <= date <= max_date
            return phase
        end
    end

    # Any other logic you want can go here

    # No specific phase for this date
    return AbstractPhase
end

"""
    get_all_subtypes(type, st=[])

Get every subtype of the provided `type` parameter.

Inputs:
- `type`: the provided type
"""
function get_all_subtypes(type, st=[])
    for subt in subtypes(type)
        push!(st,subt)
        get_all_subtypes(subt, st)
    end
    return st
end

const all_subtypes = get_all_subtypes(AbstractNode)

"""
reverse_find_first_node_name(node_tree, names)

Inputs:
- `node_tree`: A vector representing a tree of nodes to search in reverse order.
- `names`: A collection of node names to search for.

Returns:
- The first node from `node_tree` in reverse order whose name is in the `names` collection, or `nothing` if no such node is found.
"""
function reverse_find_first_node_name(node_tree,names)
    reverse_node_tree = reverse(node_tree)
    index = findfirst(n -> nodename(n.node) ∈ names,reverse_node_tree)
    if isnothing(index)
        return nothing
    else
        return reverse_node_tree[index]
    end
end


"""
revers_find_first_node_not_name(node_tree, names)

Inputs:
- `node_tree`: A vector representing a tree of nodes to search in reverse order.
- `names`: A collection of node names. The function searches for the first node from `node_tree` in reverse order whose name is not in this collection.

Returns:
- The first node from `node_tree` in reverse order whose name is not in the `names` collection, or `nothing` if no such node is found.
"""
function reverse_find_first_node_not_name(node_tree,names)
    reverse_node_tree = reverse(node_tree)
    index = findfirst(n -> nodename(n.node) ∉ names,reverse_node_tree)
    if isnothing(index)
        return nothing
    else
        return reverse_node_tree[index]
    end
end

"""
detect_node_type(node, node_tree, date, soup, PhaseType)

default setting:

Inputs:
- `node`: The XML node to determine the type for.
- `node_tree`: A vector representing a tree of nodes
- `date`: The date associated with the node.
- `soup`: The root node.
- `PhaseType`: The phase type determined from the date of XML.

Returns:
- The detected node type (`NodeType`).
"""
function detect_node_type(node, node_tree,date,soup,PhaseType)
    for NodeType in all_subtypes
        if is_nodetype(node, node_tree, NodeType, PhaseType,soup)
            return NodeType
        end
    end
end

"""
parse_node(node::Node, node_tree, io)

default setting:

Inputs:
- `node`: xml node of Node struct
- `node_tree`: A vector representing a tree of nodes for context.
- `io`: The output stream where processed data is written.
"""
function parse_node(node::Node,node_tree,io)
    process_node(node,node_tree)
end

"""
process_node(node::Node, node_tree)

default setting:

Inputs:
- `node`: xml node of Node struct
- `node_tree`: A vector representing a tree of nodes for context.

Notes:
- This function is typically invoked when no specific processing behavior is defined for the `NodeType` associated with `node`.
- Users may customize or define specific behaviors for different `NodeType` instances within their implementation.
"""
function process_node(node::Node,node_tree)
    nothing
end

function get_relink(node)
    if hasprevnode(node)
        prev = prevnode(node)
        return n -> linknext!(prev, n)
    elseif hasnextnode(node)
        next = nextnode(node)
        return n -> linkprev!(next, n)
    end
    parent = parentnode(node)
    return n -> link!(parent, n)
end

"""
"""
function write_test_xml(trigger_node, parent_node, edge_case)
    log_node = string(nameof(get_nodetype(trigger_node)))
    log_phase = string(nameof(get_phasetype(trigger_node)))
    dir_name = joinpath(@__DIR__, "../test/xmls/$log_phase/")
    create_dir(dir_name)
    fn = "$(log_node)_$(edge_case).xml"
    fn_orig_doc = "$(log_node)_$(edge_case)_orig_doc.xml"
    fn_curr_doc = "$(log_node)_$(edge_case)_curr_doc.xml"
    fpath = joinpath(dir_name, fn)
    fpath_orig_doc = joinpath(dir_name, fn_orig_doc)
    fpath_curr_doc = joinpath(dir_name, fn_curr_doc)
    if !isfile(fpath)
        orig_doc = string(document(trigger_node.node))
        write(fpath_orig_doc, orig_doc)

        #get time block
        soup = trigger_node.soup
        time_node = parentnode(findfirst("//session.header/date",soup))
        time_relink! = get_relink(time_node)

        doc = XMLDocument()
        elm = ElementNode("root")
        setroot!(doc, elm)

        unlink!(time_node)
        link!(elm,time_node)

        tree_parent = parent_node.node
        tree_parent_relink! = get_relink(tree_parent)
        unlink!(tree_parent)
        linknext!(time_node, tree_parent)

        parent = parentnode(trigger_node.node)
        parent_relink! = get_relink(parent)
        unlink!(parent)
        link!(tree_parent, parent)

        node = trigger_node.node

        prev_siblings = []
        while (hasprevnode(node))
            prior = prevnode(node)
            push!(prev_siblings,prior)
            unlink!(prior)
        end

        next_siblings = []
        while (hasnextnode(node))
            next = nextnode(node)
            push!(next_siblings, next)
            unlink!(next)
        end

        write(fpath, doc)
        unlink!(time_node)
        time_relink!(time_node)

        unlink!(tree_parent)
        tree_parent_relink!(tree_parent)
        
        unlink!(parent)
        parent_relink!(parent)

        prev_siblings = prev_siblings
        post = node
        for prior in prev_siblings
            unlink!(prior)
            linkprev!(post,prior)
            post = prior
        end

        prior = node 
        for next in next_siblings
            unlink!(next)
            linknext!(prior, next)
            prior = next
        end

        curr_doc = string(document(trigger_node.node))
        write(fpath_curr_doc, curr_doc)
        @assert orig_doc == curr_doc
        rm(fpath_curr_doc)
        rm(fpath_orig_doc)        
    end
end

"""
is_nodetype(node, node_tree, nodetype::Type{<:AbstractNode}, phase::Type{<:AbstractPhase}, soup, args...; kwargs...)

default setting:

Inputs:
- `node`: The XML node to evaluate.
- `node_tree`: A vector representing a tree of nodes for context.
- `nodetype`: A subtype of `AbstractNode` representing the type of node to check against.
- `phase`: A subtype of `AbstractPhase` representing the phase associated with the node.
- `soup`: The root node.
- `args...`: Optional additional arguments.
- `kwargs...`: Optional keyword arguments.

Returns:
- `true` if the name of `node` is found in the allowed names associated with `nodetype` for the given `phase`, `false` otherwise.

Notes:
More specific detection method for nodes is defined in nodes/
"""
function is_nodetype(node, node_tree, nodetype::Type{<:AbstractNode}, phase::Type{<:AbstractPhase}, soup, args...; kwargs...)
    NP = nodetype{phase}
    allowed_names = get_xpaths(NP)
    name = nodename(node)
    return name in allowed_names
end

"""
get_xpaths(::Type{<:N}) where {N <: AbstractNode}

This function serves as a placeholder and returns an empty array, which is meant to provide the nodenames allowed for each type. For example, speech nodes can have names "speech" or "continue". 
"""
function get_xpaths(::Type{<:N}) where {N <: AbstractNode}
    return []
end

"""find_section_title(node, node_tree, soup, section_type)

Inputs:
- `node`: The XML node from which to extract the section title.
- `node_tree`: A vector representing a tree of nodes for context.
- `soup`: The root node of the XML document.
- `section_type`: The nodenames of the types of section nodes where the title is wanted. For example, "speech".

Returns:
- The title of the specified `section_type` found within the XML document, or "N/A" if not found.
"""
function find_section_title(node,node_tree,soup,section_type)
    section_title_path = get_section_title_path(section_type)
    section_node = reverse_find_first_node_name(node_tree,get_xpaths(section_type))
    if isnothing(section_node)
        return "N/A"
    end
    title = findfirst_in_subsoup(section_node.node.path,section_title_path,soup)
    if isnothing(title)
        return "N/A"
    else
        return title.content
    end
end

"""
find_chamber(node, node_tree)

Identifies the type of chamber associated with the given XML `node`.

Inputs:
- `node`: The XML node 
- `node_tree`: A vector representing a tree of nodes for context.

Returns:
- An integer indicating the chamber type:
  - `2` for a federal chamber (`FedChamberNode`).
  - `1` for a chamber (`ChamberNode`).
  - `0` if no chamber node is found.
"""
function find_chamber(node,node_tree)
    chamber_node = reverse_find_first_node_name(node_tree,vcat(get_xpaths(ChamberNode),get_xpaths(FedChamberNode)))
    if chamber_node isa Node{<:FedChamberNode}
        return 2
    elseif chamber_node isa Node{<:ChamberNode}
        return 1
    else
#        @error "no chamber is found"
        return 0
    end
end

"""
define_flags(node::Node{<:AbstractNode{<:AbstractPhase}}, node_tree)

Generates flags based on the characteristics of the given `node`.

Inputs:
- `node`: A `Node` struct.
- `node_tree`: A vector representing a tree of nodes for context.

Returns:
- An array of flags indicating characteristics of `node`
"""
function define_flags(node::Node{<:AbstractNode{<:AbstractPhase}},parent_node,node_tree)
    ParentTypes = [QuestionNode,AnswerNode,InterjectionNode,SpeechNode]
    flags = map(node_type -> parent_node isa Node{<:node_type} ? 1 : 0, ParentTypes)
    chamber = find_chamber(node,node_tree)
    push!(flags,chamber)
    return flags
end


"""
construct_row(node, node_tree, flags, talker_contents, content)

Inputs:
- `node`: A `Node` struct.
- `node_tree`: A vector representing a tree of nodes for context.
- `flags`: An array of flags indicating characteristics of `node`.
- `talker_contents`: Contents related to speakers or talkers associated with `node`.
- `content`: Raw content associated with `node`.

Returns:
- An array (`row`) representing the data to be written to a CSV file. The row includes:
  - Flags indicating characteristics of `node`.
  - Talker contents related to speakers or talkers.
  - Cleaned text content derived from `content`.
  - Section title for `SubdebateNode`, if found.
  - Section title for `DebateNode`, if found.
  - XPath path of `node` within the XML document.
"""
function construct_row(node,node_tree,flags,talker_contents,content)
    debateinfo =  find_section_title(node,node_tree,node.soup,DebateNode)
    subdebateinfo =  find_section_title(node,node_tree,node.soup,SubdebateNode)
    row = [flags...,talker_contents...,clean_text(content),subdebateinfo,debateinfo,node.node.path]
#    @assert length(row) == 12
    return row
end
 

end


