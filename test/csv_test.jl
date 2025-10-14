function known_errors_csv(outputpath,test_outputpath)
    outputpath = joinpath(dirname(outputpath),"upload")
    input_fns = [f for (root, dirs, files) in walkdir(outputpath) for f in joinpath.(root, files) if endswith(f, ".csv")]
    output_fn = joinpath(test_outputpath,"csv_test.csv")
    open(output_fn, "w") do io
        for input_fn in input_fns
            csvfile = CSV.File(input_fn)
            headers_ = copy(propertynames(csvfile))
            header_to_num = edit_set_up(headers_)
            rows = eachrow(csvfile)
            for row in rows
                row_ = @. collect(row)
                row = row_[1]
                flagged,flag = if_flag(row,header_to_num)
                if flagged
                    pushfirst!(row, input_fn, flag)
                    println(io, row)
                end
            end
        end
    end
end

function if_flag(row,header_to_num)
    for f in [speaker_flag]
        check = f(row,header_to_num)
        if !check
            return true, f
        end
    end
    return false, "N/A"
end

function speaker_flag(row,header_to_num)
    content = row[header_to_num[:content]]
    check = @. occursin(["SPEAKER","DEPUTY SPEAKER"], content)
    return iszero(check)
end



