using ParlinfoSpeechScraper
using EzXML
using InteractiveUtils
using Test

const RunModule = ParlinfoSpeechScraper.RunModule

@testset verbose = true "AbstractPhase" begin
    @test begin
        files = readdir(joinpath(@__DIR__,"xmls/AbstractPhase/"))
        output_path = joinpath(dirname(@__FILE__),"result/AbstractPhase")
        for file in files
            date = RunModule.run_xml(joinpath(@__DIR__,"xmls/AbstractPhase/$file"),output_path,false,true)
            mv(joinpath(output_path,"$(date)_edit_step1.csv"),joinpath(output_path,"$(date)_edit_step1_$(file[1:end-4]).csv"),force=true)
            mv(joinpath(output_path,"$(date)_edit_step2.csv"),joinpath(output_path,"$(date)_edit_step2_$(file[1:end-4]).csv"),force=true)
            mv(joinpath(output_path,"$(date).csv"),joinpath(output_path,"$(date)_$(file[1:end-4]).csv"),force=true)
        end
        
        current_files = readdir(output_path)
        current_csvs = filter(f -> endswith(f, ".csv"), current_files)
        for file in current_files
            curr = joinpath(output_path,file)
            correct = joinpath("$(output_path)/correct/",file)
            file_curr = open(curr, "r") do f
                readlines(f)
            end

            file_correct = open(correct, "r") do f
                readlines(f)
            end
            if file_curr != file_correct
                @info file_curr
                return false
            end
       end
    true
    end

end


