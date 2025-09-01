function speaker_time(input_fn,output_fn,::Type{<:AbstractEditPhase})
    csvfile = CSV.File(input_fn)
    headers_ = copy(propertynames(csvfile))
    header_to_num = edit_set_up(headers_)
    #any additional headers needed
    for header in [:Speaker,:Time, :Other]
        push!(headers_,header)
    end
    rows = eachrow(csvfile)
  
    open(output_fn, "w") do io
        write_row_to_io(io,string.(headers_))
        for row in rows
            row_ = @. collect(row)
            row = row_[1]
            row = edit_out_time_content_row(row,header_to_num) 
            row = other_information(row,header_to_num) 
            write_row_to_io(io,row)
        end
    end
end

function is_name(name)
    if name in ["Bill", "Committee"]
        return false
    end
    
    number = length(split(name," "))
    if number > 5
        return false
    end

    if occursin(r"\d",name)
        return false
    end
    return true    
end

function other_information(row,header_to_num)
    name = row[header_to_num[:name]]
    function return_row(row,other_content)
        row[header_to_num[Symbol("name.id")]] = "N/A"
        row[header_to_num[:name]] = "N/A"
        return vcat(row,[other_content])
    end
    if !is_name(name)
        id_ = row[header_to_num[Symbol("name.id")]]
        if id_ != "N/A"
            other_content = name * " " * id_
            return return_row(row,other_content)
        else
            other_content = name
            return return_row(row,other_content)
        end
    else
        return vcat(row,["N/A"])
    end
end

function edit_out_time_content_row(row,header_to_num)
    content_num = header_to_num[:content]
    content = row[content_num]
    new_content = edit_out_time_content(content)
    row[content_num] = new_content[1]
    new_row = vcat(row,[new_content[2],new_content[3]])
    return new_row
end

function edit_out_time_content(cell)
    pattern = r"\(\d{2}:\d{2}\):"
    match_ = match(pattern,cell)
    if isnothing(match_) 
        return [cell,"N/A","N/A"]
    else
        match_ = match_.match
        split_cell = split(cell,match_)
        return [split_cell[2],split_cell[1],match_]
    end
end
 
