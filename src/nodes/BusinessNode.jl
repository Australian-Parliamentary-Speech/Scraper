export BusinessNode

abstract type BusinessNode <: AbstractNode end


function get_xpaths(year,::Type{BusinessNode})
   phase_to_dict = Dict(
                        :phase1 => ["business.start"]) 
    return  phase_to_dict[year_to_phase(year)]
end



