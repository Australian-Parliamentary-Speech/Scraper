abstract type PhaseSGML <: AbstractPhase end

# Get Phase Node Overrides
phase_node_path = joinpath(@__DIR__, "nodes")

for path in readdir(phase_node_path, join=true)
    if isfile(path)
        include(path)
    end
end

upperbound = date_to_float(1997,12,12)
date_to_phase[(1981.0,upperbound)] = PhaseSGML


function define_flags(node::Node{<:AbstractNode{PhaseSGML}},parent_node,node_tree)
    ParentTypes = [QuestionNode,AnswerNode,InterjectionNode,SpeechNode,PetitionNode,QuoteNode_{PhaseSGML},MotionnospeechNode]
    headers = ["question_flag","answer_flag","interjection_flag","speech_flag","petition_flag","quote_flag","motionnospeech_flag"]
    flags = map(node_type -> parent_node isa Node{<:node_type} ? 1 : 0, ParentTypes)
    header_and_flag = zip(headers,flags)
    for couple in header_and_flag
        node.headers_dict[couple[1]] = couple[2]
    end
    chamber = find_chamber(node,node_tree)

    # add a non-speech node in there
    title = find_section_title(node_tree,node.soup,DebateNode{PhaseSGML})
    if !(1 ∈ flags) && (node.headers_dict["name"] =="N/A") && (title == "NOTICES" || title == "PAPERS")
        node.headers_dict["nonspeech"] = 1
    else
        node.headers_dict["nonspeech"] = 0
    end
end


function define_headers(::Type{PhaseSGML})
    headers = ["question_flag","answer_flag","interjection_flag","speech_flag","petition_flag","quote_flag","motionnospeech_flag","chamber_flag","nonspeech","name","name.id","electorate","party","role","page.no","content","subdebateinfo","debateinfo","path"]
    headers_dict = OrderedDict(headers .=> ["N/A" for h in headers])
    return headers_dict
end

function write_test_xml(trigger_node::Node{<:AbstractNode{PhaseSGML}}, parent_node, edge_case)
    if isnothing(edge_case)
        return 
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
    log_node = string(nameof(get_nodetype(trigger_node)))
    log_phase = string(nameof(get_phasetype(trigger_node)))
    dir_name = joinpath(@__DIR__, "../../../../test/xmls/$log_phase/")
    create_dir(dir_name)
    fn = "$(log_node)_$(edge_case).xml"
    fn_orig_doc = "$(log_node)_$(edge_case)_orig_doc.xml"
    fn_curr_doc = "$(log_node)_$(edge_case)_curr_doc.xml"
    fpath = joinpath(dir_name, fn)
    fpath_orig_doc = joinpath(dir_name, fn_orig_doc)
    fpath_curr_doc = joinpath(dir_name, fn_curr_doc)
   if !isfile(fpath)
        orig_doc = string(document(trigger_node.soup))
        write(fpath_orig_doc, orig_doc)
        #get time block
        soup = trigger_node.soup
        time_node = parentnode(findfirst("//hansard",soup))
        time_relink! = get_relink(time_node)

        doc = XMLDocument()
        elm = ElementNode("root")
        setroot!(doc, elm)

        unlink!(time_node)
        link!(elm,time_node)
        tree_parent = parent_node.node
        parent = parentnode(trigger_node.node)
 
        if tree_parent != parent        
            tree_parent_relink! = get_relink(tree_parent)
            unlink!(tree_parent)
            linknext!(time_node, tree_parent)
        end

        parent_relink! = get_relink(parent)
        unlink!(parent)
        if tree_parent != parent
            link!(tree_parent, parent)
        else
            linknext!(time_node,parent)
        end
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
        
        if tree_parent != parent
            unlink!(tree_parent)
            tree_parent_relink!(tree_parent)
        end

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

        curr_doc = string(document(trigger_node.soup))
        write(fpath_curr_doc, curr_doc)
        @assert orig_doc == curr_doc
        rm(fpath_curr_doc)
        rm(fpath_orig_doc)        
    end
end


