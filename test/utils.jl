using CSV

function get_row(row)
    row_ = @. collect(row)
    row = row_[1]
    return row 
end

function collect_row(row)
    row_ = @. collect(row)
    row = row_[1]
    return row
end
 

function edit_set_up(headers)
    return Dict(zip(headers,collect(1:length(headers)))) 
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

function get_all_csv_subdir(path)
    all = readdir(glob"*/*.csv", path)
    return all
end

function get_all_xml_subdir(path)
    all = readdir(glob"*/*.xml", path)
    return all
end
