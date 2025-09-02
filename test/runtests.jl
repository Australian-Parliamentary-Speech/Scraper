using ParlinfoSpeechScraper
using EzXML
using InteractiveUtils
using Test
using CSV, DataFrames
using Glob
using BetterInputFiles
using Dates
using Random
include(joinpath(@__DIR__, "utils.jl"))
include(joinpath(@__DIR__, "similarity_funcs.jl"))


const RunModule = ParlinfoSpeechScraper.RunModule
using ParlinfoSpeechScraper.RunModule.EditModule
using ParlinfoSpeechScraper.RunModule.Utils

struct test_struct
    skip_cols::Vector{Any}
    which_test::Symbol
    fuzzy_search::Vector{Int64}
end

function setup(which_house)
    tomlpath = "../Inputs/hansard/$(which_house).toml"
    toml = setup_input(tomlpath,false)
    global_options = toml["GLOBAL"]
    outputpath = global_options["OUTPUT_PATH"]
    xml_path_toml = toml["XML_DIR"][1]
    xml_path = xml_path_toml["PATH"]
    inputpath = joinpath(dirname(tomlpath),xml_path)
    return inputpath,outputpath
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



function get_all_csv_dates(outputpath,testpath,which_house)
    function find_all_csv_dates(all_csv_names)
        simple_list = []
        for name in all_csv_names
            date_match = match(r"\d+-\d+-\d+",name)
            date = date_match.match
            push!(simple_list,date) 
        end
        return unique(simple_list)
    end
    all_csv_names = get_all_csv_subdir(outputpath)
    all_csv_dates = find_all_csv_dates(all_csv_names)
    years = [split(date,"-")[1] for date in all_csv_dates]
    fn = joinpath("dates","all_csv_dates_$(which_house).csv")
    open(fn, "w") do io
        for (x,y) in zip(years, all_csv_dates)
            println(io, "$x,$y")
        end
    end
    return fn
end

function get_all_xml_dates(inputpath,testpath,which_house)
    function find_all_xml_dates(all_xml_names)
        simple_list = []
        for name in all_xml_names
            date_match = match(r"\d+_\d+_\d+",name)
            date = date_match.match
            date = replace(date, "_" => "-")
            push!(simple_list,date) 
        end
        return unique(simple_list)
    end
    all_xml_names = get_all_xml_subdir(inputpath)
    all_xml_dates = find_all_xml_dates(all_xml_names)
    years = [split(date,"-")[1] for date in all_xml_dates]
    fn = joinpath("dates","all_xml_dates_$(which_house).csv")
    open(fn, "w") do io
        for (x,y) in zip(years, all_xml_dates)
            println(io, "$x,$y")
        end
    end
    return fn
end


function read_sitting_dates(testpath)
    csvfile = CSV.File(joinpath([testpath,"dates","sitting_dates.csv"]))
    rows = eachrow(csvfile)
    house = []
    senate = []
    for row in rows
        row_ = @. collect(row)
        row = row_[1]
        date_ = row[1]
        year,month,day = Dates.year(date_), Dates.month(date_), Dates.day(date_)
        if month < 10
            month = "0$month"
        end
        if day < 10
            day = "0$day"
        end
        if_senate = row[3]
        if_house = row[2]
        if if_senate
            push!(senate,Date("$(year)-$(month)-$(day)"))
        end
        if if_house
            push!(house,Date("$(year)-$(month)-$(day)"))
        end 
    end
    return house, senate
end

function compare_gold_standard(outputpath, testpath,test_setup,test_output_path)
    gold_standard_path = joinpath(testpath,"gold_standard")
    sample_csv_path = joinpath(testpath,"sample_csv")
    create_dir(sample_csv_path)
    gold_standard_csvs = get_all_csvnames(gold_standard_path)
    get_sample_csvs(outputpath,gold_standard_csvs,sample_csv_path)
    similarity_ratio(gold_standard_csvs,sample_csv_path, test_output_path,test_setup) 
end

function similarity_ratio(gold_standard_csvs,sample_csv_path, test_output_path,test_setup)
    fn = joinpath(test_output_path,"similarity_test.csv")
    open(fn,"w") do io
        for gs_csv in gold_standard_csvs
            gs_name = basename(gs_csv)

            sample_csv = joinpath(sample_csv_path,gs_name)
            @show "Comparing now $gs_name to $sample_csv"
            ratio = similarity_csv(gs_csv,sample_csv,test_setup,test_output_path)
            @show ratio
            println(io,"\"$gs_name\",$ratio") 
       end
    end
end


@testset verbose = true "Test set" begin
    which_house = :house
    inputpath, outputpath = setup(which_house)
    sitting_house, sitting_senate = read_sitting_dates(@__DIR__)
    @test begin
        skip_cols = [:speaker_no,:stage_direction_flag,Symbol("page.no"),:Other,:electorate,:party,:role]
        which_test = [:exact,:fuzzy][2]
        fuzzy_search = [2,5]
        test_setup = test_struct(skip_cols,which_test,fuzzy_search)
        test_output_path = joinpath(@__DIR__,"test_outputs")
        create_dir(test_output_path)
        compare_gold_standard(outputpath, @__DIR__,test_setup, test_output_path)
        true
    end

#    @test begin
#        csv_fn = get_all_csv_dates(outputpath,@__DIR__,which_house)
#        xml_fn = get_all_xml_dates(inputpath,@__DIR__,which_house)
#
#        xml = CSV.read(xml_fn, DataFrame,header=false)
#        csv = CSV.read(csv_fn, DataFrame,header=false)
#
#        xmls = xml[:, 2]
#        csvs = csv[:, 2]
#        only_in_xml = setdiff(xmls, csvs)
#        only_in_csv = setdiff(csvs, xmls)
#        if which_house == :senate
#            only_in_sitting = setdiff(sitting_senate,xmls)
#        elseif which_house == :house
#            only_in_sitting = setdiff(sitting_house,xmls)
#        end
#        open(joinpath("dates","only_in_xml_$(which_house).csv"), "w") do io
#            for date in only_in_xml
#            println(io, date)
#            end
#        end
#        open(joinpath("dates","only_in_sitting_$(which_house).csv"), "w") do io
#            for date in only_in_sitting
#                println(io, date)
#            end
#        end
# 
#        true
#    end
end


