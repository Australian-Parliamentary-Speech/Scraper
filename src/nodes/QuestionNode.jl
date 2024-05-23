export QuestionNode

abstract type QuestionNode <: AbstractNode end


function process_node(node::Node{QuestionNode},node_tree,year,soup)
    phase = year_to_phase(year,QuestionNode)
    if phase == :phase1
        nothing
    else
        @error "Node not processed"
    end
end

function is_nodetype(node, node_tree,::Type{QuestionNode}, args...; kwargs...)
    year = kwargs[:year]
    soup = args[1]
    allowed_names = get_xpaths(year,QuestionNode)
    name = nodename(node)
    try
        title = find_debate_title(node,node_tree,soup)
        if title == "QUESTIONS WITHOUT NOTICE"
            return name in allowed_names
        else
            return false
        end
    catch
        return false
    end
end


function get_xpaths(year,::Type{QuestionNode})
   phase_to_dict = Dict(
                        :phase1 => ["question","answer"]) 
    return  phase_to_dict[year_to_phase(year,QuestionNode)]
end

function year_to_phase(year,::Type{QuestionNode})
    if 2020 < year < 2024
        return :phase1
    else
        @error "No phase was produced in questionnode"
    end
end

