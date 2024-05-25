export InterjectionNode

abstract type InterjectionNode <: AbstractNode end


function get_xpaths(year,::Type{InterjectionNode})
   phase_to_dict = Dict(
                        :phase1 => ["interjection","continue"]) 
    return  phase_to_dict[year_to_phase(year)]
end

