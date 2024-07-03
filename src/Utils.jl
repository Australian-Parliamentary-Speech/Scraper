module Utils

export write_row_to_io
export create_dir
export date_to_float

function date_to_float(year,month,day)
    return round(year + month/120 + day/3100,digits=6)
end

function create_dir(directory_path::String)
    if !isdir(directory_path)
        mkpath(directory_path)
    end
end


function create_dict_multiple_values(keys,values)
    d = Dict()
    for key in keys
        d[key] = push!(get(d,key,[]),value)
    end
    return d
end


function edit_row(row)
    edit_row = ""
    for i in row
        i = replace(string(i), "\"" => "\'")
        edit_row = edit_row * "\"$i\","
    end
    return edit_row[1:end-1]
end

function replace_empty_string(row)
    return map(x -> isempty(x) ? "N/A" : x, row)
end

function write_row_to_io(io,row)
    row = replace_empty_string(row)
    edit_row_ = edit_row(row)
    println(io,edit_row_)
end



end
