module Util

function create_dict_multiple_values(keys,values)
    d = Dict()
    for key in keys
        d[key] = push!(get(d,key,[]),value)
    end
    return d
end
end
