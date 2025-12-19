function stage_direction(input_fn,output_fn,::Type{<:AbstractEditPhase})
    csvfile = CSV.File(input_fn)
    headers_ = copy(propertynames(csvfile))
    header_to_num = edit_set_up(headers_)
    rows = eachrow(csvfile)
    stage_directions = [
    r"(?i)A division having been called in the House of Representatives",
    r"(?i)Sitting suspended from",
    r"(?i)Debate adjourned",
    r"(?i)Federation Chamber adjourned at",
    r"(?i)Question agreed to",
    r"(?i)Question resolved in the affirmative",
    r"(?i)Bill read a second time",
    r"(?i)Message from the Governor-General recommending appropriation announced",
    r"(?i)Report adopted",
    r"(?i)Bill read a .+ time",
    r"(?i)Leave granted",
    r"(?i)Senate adjourned"
    ]

    open(output_fn, "w") do io
        write_row_to_io(io,string.(headers_))
        for row in rows
            row_ = @. collect(row)
            row = row_[1]
            content = row[header_to_num[:content]]
            for sd in stage_directions
                if occursin(sd,content) || row[header_to_num[:chamber_flag]] == 3
                    flag_indices,all_flags = find_all_flags(row,header_to_num)
                    for i in flag_indices
                        row[i] = 0
                    end
                    if occursin(sd,content)
                        row[header_to_num[:name]] = "N/A"
                        row[header_to_num[Symbol("name.id")]] = "N/A"
                    end
                end
            end
                
            if content != ""
                write_row_to_io(io,row)
            end
        end
    end
end

