function check_csv(outputpath)
    input_fns = [f for (root, dirs, files) in walkdir(outputpath) for f in joinpath.(root, files) if endswith(f, ".csv")]
    for input_fn in input_fns
        csvfile = CSV.File(input_fn)
        headers_ = copy(propertynames(csvfile))
        header_to_num = edit_set_up(headers_)
        rows = eachrow(csvfile)
        for row in rows
            row_ = @. collect(row)
            row = row_[1]
        end
    end
end

