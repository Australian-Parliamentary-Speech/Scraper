export DivisionNode

abstract type DivisionNode <: AbstractNode end


function get_xpaths(year,::Type{DivisionNode})
    phase_to_dict = Dict(
                        :phase1 => ["division"]) 
    return  phase_to_dict[year_to_phase(year)]
end

