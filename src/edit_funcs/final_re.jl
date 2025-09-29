function final_re(input_fn,output_fn,::Type{<:AbstractEditPhase})
    csvfile = CSV.File(input_fn)
    headers_ = copy(propertynames(csvfile))
    header_to_num = edit_set_up(headers_)
    rows = eachrow(csvfile)
  
    open(output_fn, "w") do io
        write_row_to_io(io,string.(headers_))
        for row in rows
            row_ = @. collect(row)
            row = row_[1]
            row = edit_row(row,header_to_num)
            content = row[header_to_num[:content]]
            if content != ""
                write_row_to_io(io,row)
            end
        end
    end
end

function edit_row(row,header_to_num)
    row = remove_bits(row,header_to_num)
end

