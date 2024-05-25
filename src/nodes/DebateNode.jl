export DebateNode

abstract type DebateNode <: AbstractNode end


function get_xpaths(year,::Type{DebateNode})
    phase_to_dict = Dict(
                        :phase1 => ["debate"]) 
    return  phase_to_dict[year_to_phase(year)]
end


