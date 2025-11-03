
function clean_gs_files()
    test_dir = @__DIR__
    original_gs_dir = joinpath([test_dir,"gold_standard","original"])
    gs_csvs = get_all_csvnames(original_gs_dir)
    for gs_csv in gs_csvs
        csvfile = CSV.File(gs_csv)
        headers_ = copy(propertynames(csvfile))
        header_to_num = edit_set_up(headers_)
        rows = eachrow(csvfile)
        output_fn = joinpath([test_dir, "gold_standard",basename(gs_csv)])
        open(output_fn, "w") do io
            write_row_to_io(io,string.(headers_))
            for row in rows
                row_ = @. collect(row)
                row = row_[1]
                row = edit_row_gs(row,header_to_num)
#                row = edit_row(row,header_to_num)
                write_row_to_io(io,row)
            end
        end
    end
end

function edit_row_gs(row,header_to_num)
    content_num = header_to_num[:content]
    content = row[content_num]
    #removes trailing spaces in the end
    content = replace(content, r" +$" => "")
    #removes leading dashes or dots
    content = replace(content, r"^\s*[.\-—–]+\s*" => "")
    #change any double space to single space
    content = replace(content, r" +" => " ")
    row[content_num] = content
    #replace missing values with "N/A"
    row = [ismissing(cell) ? "N/A" : cell for cell in row]
    return row
end


 
