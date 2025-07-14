using CSV

function collect_row(row)
    row_ = @. collect(row)
    row = row_[1]
    return row
end
 
function compare_csv(csv1,csv2)
    csvfile1 = CSV.File(csv1)
    csvfile2 = CSV.File(csv2)
    rows1 = eachrow(csvfile1)
    rows2 = eachrow(csvfile2)
    if length(rows1) == length(rows2)
        rows_mismatched = ""
        for i in 1:length(rows1)
            crow1 = collect_row(rows1[i])
            crow2 = collect_row(rows2[i])
            if crow1 != crow2
                rows_mismatched = rows_mismatched * "\"$(i+1)\","
            end
        end
    else
        rows_mismatched = "length not equal"
    end
    return rows_mismatched
end

function create_dir(directory_path::String)
    if !isdir(directory_path)
        mkpath(directory_path)
    end
end

function check_csv(curr,correct)
    file_curr = open(curr, "r") do f
        readlines(f)
    end

    file_correct = open(correct, "r") do f
        readlines(f)
    end

    return file_curr == file_correct
end

function get_all_csvnames(path)
    all = readdir(glob"*.csv", path)
    return all
end
