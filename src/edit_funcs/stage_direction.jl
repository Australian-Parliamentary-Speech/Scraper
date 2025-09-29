function stage_direction(input_fn,output_fn,::Type{<:AbstractEditPhase})
    csvfile = CSV.File(input_fn)
    headers_ = copy(propertynames(csvfile))
    header_to_num = edit_set_up(headers_)
    rows = eachrow(csvfile)

    stage_directions = ["A division having been called in the House of Representatives","Sitting suspended from","Debate adjourned", "Federation Chamber adjourned at"]
  
    open(output_fn, "w") do io
        write_row_to_io(io,string.(headers_))
        for row in rows
            row_ = @. collect(row)
            row = row_[1]
            content = row[header_to_num[:content]]
            for sd in stage_directions
                if occursin(sd,content)
                    flag_indices,all_flags = find_all_flags(row,header_to_num)
                    for i in flag_indices
                        row[i] = 0
                    end
                end
            end
                
            if content != ""
                write_row_to_io(io,row)
            end
        end
    end
end

