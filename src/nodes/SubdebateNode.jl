export SubdebateNode

abstract type SubdebateNode <: AbstractNode end


function get_xpaths(year,::Type{SubdebateNode})
    phase_to_dict = Dict(
                        :phase1 => ["subdebate.1"]) 
    return  phase_to_dict[year_to_phase(year)]
end

