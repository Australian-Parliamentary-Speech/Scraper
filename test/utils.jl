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


function get_sample_csvs(outputpath,gold_standard_csvs,sample_dir,test_setup)
   for gs_csv in gold_standard_csvs
        gs_name = basename(gs_csv)
        year = split(gs_name,"-")[1]
        sample_name = from_gs_to_sample(gs_name,test_setup)
        sample_file_name = joinpath([outputpath, year, sample_name])
        dir_file_name = joinpath(sample_dir, sample_name)
        cp(sample_file_name, dir_file_name,force=true)
    end
end


function remove_files(output_path,remove_num)
    function remove_check(file,num)
        if num != 0
            return occursin("step$(num).csv", file)
        elseif num == 0
            return occursin(r"\d", file) && !(occursin("step", file))
        end
    end

    for num in remove_num
        for file in readdir(output_path)
            if remove_check(file,num)
                rm(joinpath(output_path, file))
            end
        end
    end
end

