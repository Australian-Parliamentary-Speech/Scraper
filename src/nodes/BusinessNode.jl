export BusinessNode

abstract type BusinessNode{P} <: AbstractNode{P} end


function get_xpaths(::Type{<:BusinessNode})
   return ["business.start"]
end



