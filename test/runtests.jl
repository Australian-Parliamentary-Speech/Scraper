using ParlinfoSpeechScraper
using EzXML
using InteractiveUtils
using Test
using CSV

const RunModule = ParlinfoSpeechScraper.RunModule

function check_csv(curr,correct)
    file_curr = open(curr, "r") do f
        readlines(f)
    end

    file_correct = open(correct, "r") do f
        readlines(f)
    end
    return file_curr == file_correct
end 


#this set of test looks at before edit only.
@testset verbose = false "AbstractPhase" begin
    @test  begin
        files = readdir(joinpath(@__DIR__,"xmls/AbstractPhase/"))
        output_path = joinpath(dirname(@__FILE__),"step1_result/AbstractPhase")
        for file in files
            date = RunModule.run_xml(joinpath(@__DIR__,"xmls/AbstractPhase/$file"),output_path,false,false)
#            mv(joinpath(output_path,"$(date)_edit_step1.csv"),joinpath(output_path,"$(date)_edit_step1_$(file[1:end-4]).csv"),force=true)
#            mv(joinpath(output_path,"$(date)_edit_step2.csv"),joinpath(output_path,"$(date)_edit_step2_$(file[1:end-4]).csv"),force=true)
            mv(joinpath(output_path,"$(date).csv"),joinpath(output_path,"$(date)_$(file[1:end-4]).csv"),force=true)
        end
        
        current_files = readdir(output_path)
        current_csvs = filter(f -> endswith(f, ".csv"), current_files)
        for file in current_files
            curr = joinpath(output_path,file)
            correct = joinpath("$(output_path)/correct/",file)
            if !check_csv(curr,correct)
                return false
            end
      end
    true 
    end
end

@testset verbose = true "Edit" begin
    @test begin
        PhaseType = AbstractPhase
        test_path = joinpath(@__DIR__,"csvs/AbstractPhase")
        test_files = readdir(test_path)
        test_csvs = filter(f -> endswith(f, ".csv"), test_files)
        for test_csv in test_csvs
            RunModule.EditModule.edit_csv(joinpath(test_path,test_csv),PhaseType)
        end
        result_files = readdir(test_path)
        result_csvs = filter(f -> occursin("step", f), result_files)
        for result_csv in result_csvs
            mv(joinpath(test_path,result_csv),joinpath(@__DIR__,"step2_result/AbstractPhase/$result_csv"),force=true)
        end
        for result_csv in result_csvs
            curr = joinpath(@__DIR__,"step2_result/AbstractPhase/$result_csv")
            correct = joinpath(@__DIR__,"step2_result/AbstractPhase/correct/$result_csv")
            if !check_csv(curr,correct)
                return false
            end
        end
       true         
    end
end

function get_all_dates(outputpath,testpath)
    function editrow(row)
        edit_row = ""
        for i in row
            i = replace(string(i), "\"" => "\'")
            edit_row = edit_row * "\"$i\","
        end
    end

    integer_pattern = r"^\d+$"
    year_dirs = filter(name -> isdir(joinpath(outputpath, name)) && occursin(integer_pattern, name), readdir(outputpath))
    open(joinpath(testpath,"summary_all_dates.csv"), "w") do io
        for year_dir in year_dirs
            dir_ = joinpath(outputpath,year_dir)
            files = filter(name -> isfile(joinpath(dir_, name)) && endswith(name, "edit_step2.csv"), readdir(dir_))
            row = [replace(filename, r"_edit_step2\.csv$" => "") for filename in files]
            write(io,join(vcat([year_dir],row),","),"\n")
        end
    end

    open(joinpath(testpath,"summary_speaker_coverage.csv"), "w") do io
        for year_dir in year_dirs
            dir_ = joinpath(outputpath,year_dir)
            files = filter(name -> isfile(joinpath(dir_, name)) && endswith(name, "edit_step2.csv"), readdir(dir_))
            speaker_no = 0
            missing_speaker_no = 0
            for file in files
                csvfile = CSV.File(joinpath(dir_,file))
                rows = eachrow(csvfile)
                headers_ = copy(propertynames(csvfile))
                header_to_num = RunModule.EditModule.edit_set_up(headers_)
                for row in rows
                    if !RunModule.EditModule.is_stage_direction(row,header_to_num)
                        row = @. collect(row)
                        row_ = row[1]
                        if row_[header_to_num[Symbol("name.id")]] != "N/A"
                            speaker_no += 1
                        else
                            missing_speaker_no += 1
                        end
                    end
                end
            end
            println(io,join([year_dir, speaker_no, missing_speaker_no, speaker_no/(speaker_no+missing_speaker_no)],","))
        end
    end
end

@testset verbose = true "Summary" begin
    @test begin
        path = pathof(ParlinfoSpeechScraper)
        outputpath = joinpath(dirname(dirname(path)),"Outputs/hansard")
        get_all_dates(outputpath,@__DIR__)
        true
    end
end
 

