using ParlinfoSpeechScraper
using EzXML
using InteractiveUtils
using Test

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

