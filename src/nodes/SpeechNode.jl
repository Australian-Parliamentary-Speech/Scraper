export SpeechNode

abstract type SpeechNode <: AbstractNode end


function process_node(node::Node{SpeechNode},node_tree,year,soup)
    phase = year_to_phase(year,SpeechNode)
    if phase == :phase1
        nothing
    else
        @error "Node not processed"
    end
end


function is_nodetype(node, node_tree,::Type{SpeechNode}, args...; kwargs...)
    year = kwargs[:year]
    soup = args[1]
    allowed_names = get_xpaths(year,SpeechNode)
    name = nodename(node)
    try
        title = find_debate_title(node,node_tree,soup)
        if title != "QUESTIONS WITHOUT NOTICE"
            return name in allowed_names
        else 
            return false
        end
    catch e
        @error e
        return false
    end
end

function get_xpaths(year,::Type{SpeechNode})
    phase_to_dict = Dict(
                         :phase1 => ["speech","question","answer"]) 
    return  phase_to_dict[year_to_phase(year,SpeechNode)]
end

function year_to_phase(year,::Type{SpeechNode})
    if 2020 < year < 2024
        return :phase1
    else
        @error "No phase was produced in speechnode"
    end
end

