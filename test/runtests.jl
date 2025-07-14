using ParlinfoSpeechScraper
using EzXML
using InteractiveUtils
using Test
using CSV
using Glob
using BetterInputFiles
include(joinpath(@__DIR__, "utils.jl"))

const RunModule = ParlinfoSpeechScraper.RunModule
using ParlinfoSpeechScraper.RunModule.EditModule

function setup()
    input_path = "../Inputs/hansard/hansard.toml"
    toml = setup_input(input_path,false)
    global_options = toml["GLOBAL"]
    output_path = global_options["OUTPUT_PATH"] 
    return output_path
end

function get_sample_csvs(outputpath,gold_standard_csvs,sample_dir)
    for gs_csv in gold_standard_csvs
        gs_name = basename(gs_csv)
        year = split(gs_name,"-")[1]
        sample_file_name = joinpath([outputpath, year, gs_name])
        dir_file_name = joinpath(sample_dir, gs_name)
        cp(sample_file_name, dir_file_name,force=true)
    end
end


function compare_outputs(gold_standard_csvs,sample_csv_path,testpath)
    fn = joinpath(testpath,"compatibility_test.csv")
    open(fn,"w") do io
        for gs_csv in gold_standard_csvs
            gs_name = basename(gs_csv)
            sample_csv = joinpath(sample_csv_path,gs_name)
            mismatched = compare_csv(gs_csv,sample_csv)
            println(io,"\"$gs_name\","*mismatched)
        end
    end
end

function compare_gold_standard(outputpath, testpath)
    gold_standard_path = joinpath(testpath,"gold_standard")
    sample_csv_path = joinpath(testpath,"sample_csv")
    create_dir(sample_csv_path)
    gold_standard_csvs = get_all_csvnames(gold_standard_path)
    get_sample_csvs(outputpath,gold_standard_csvs,sample_csv_path)
    compare_outputs(gold_standard_csvs, sample_csv_path,testpath)
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


@testset verbose = true "Test set" begin
    @test begin
        outputpath = setup()
        compare_gold_standard(outputpath, @__DIR__)
        true
    end

#    @test begin
#        outputpath = setup()
#        get_all_dates(outputpath,@__DIR__)
#        true
#    end
end
 


