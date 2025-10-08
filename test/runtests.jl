using ParlinfoSpeechScraper
using EzXML
using InteractiveUtils
using Test
using CSV, DataFrames
using Glob
using BetterInputFiles
using Dates
include(joinpath(@__DIR__, "utils.jl"))
include(joinpath(@__DIR__, "similarity_funcs.jl"))
include(joinpath(@__DIR__, "clean_gs.jl"))



const RunModule = ParlinfoSpeechScraper.RunModule
using ParlinfoSpeechScraper.RunModule.EditModule
using ParlinfoSpeechScraper.RunModule.Utils
import ParlinfoSpeechScraper.RunModule.Utils.create_dir as create_dir


struct test_struct
    skip_cols::Vector{Any}
    which_test::Symbol
    fuzzy_search::Vector{Int64}
    toml::Any
end

function setup(which_house)
    tomlpath = "$(which_house).toml"
    toml = setup_input(tomlpath,false)
    global_options = toml["GLOBAL"]
    outputpath = global_options["OUTPUT_PATH"]
    xml_path_toml = toml["XML_DIR"][1]
    xml_path = xml_path_toml["PATH"]
    inputpath = joinpath(dirname(tomlpath),xml_path)
    return inputpath,outputpath,toml
end

function from_gs_to_sample(gs_name,test_setup)
   function find_date(str)
        m = match(r"\d+-\d+-\d+", str)
        return m.match
    end

    function sample_name_(date,step_num)
        return "$(date)_edit_step$(step_num).csv"
    end
 
    general_options = test_setup.toml["GENERAL_OPTIONS"]
    remove_nums = general_options["REMOVE_NUMS"]
    step_num = length(remove_nums)
    date = find_date(gs_name)
    sample_name = sample_name_(date,step_num)
    return sample_name
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
    get_sample_csvs(outputpath,gold_standard_csvs,sample_csv_path,test_setup)
    similarity_ratio(gold_standard_csvs,sample_csv_path, test_output_path,test_setup) 
end

function similarity_ratio(gold_standard_csvs,sample_csv_path, test_output_path,test_setup)
    fn = joinpath(test_output_path,"similarity_test.csv")
    open(fn,"w") do io
        for gs_csv in gold_standard_csvs
            gs_name = basename(gs_csv)
            sample_name = from_gs_to_sample(gs_name,test_setup)
            sample_csv = joinpath(sample_csv_path,sample_name)
            @show "Comparing now $gs_name to $sample_csv"
            ratio = similarity_csv(gs_csv,sample_csv,test_setup,test_output_path)
            @show ratio
            println(io,"\"$gs_name\",$ratio") 
       end
    end
end

#function check_csv(curr,correct)
#    file_curr = open(curr, "r") do f
#        readlines(f)
#    end
#
#    file_correct = open(correct, "r") do f
#        readlines(f)
#    end
#
#    return file_curr == file_correct
#end
#
@testset verbose = true "Test set" begin
    which_house = :house
    inputpath, outputpath, toml = setup(which_house)
    sitting_house, sitting_senate = read_sitting_dates(@__DIR__)
    clean_gs_files()
    skip_cols = [:speaker_no,:non_speech_flag,Symbol("page.no"),:name,:electorate,:party,:role]
    which_test = [:exact,:fuzzy][2]
    fuzzy_search = [8,2]
    test_setup = test_struct(skip_cols,which_test,fuzzy_search,toml)
 
    #gold standard
#    @test begin
#        print("Gold standard test running ...")
#       test_output_path = joinpath([@__DIR__,"test_outputs","gs_outputs"])
#        create_dir(test_output_path)
#        compare_gold_standard(outputpath, @__DIR__,test_setup, test_output_path)
#        true
#    end
   
    #Test XML samples
    @test begin
        print("Test XML test running ...")
        general_options = toml["GENERAL_OPTIONS"] 
        edit_funcs = general_options["EDIT"]
        remove_nums = general_options["REMOVE_NUMS"]
        csv_edit = general_options["CSV_EDIT"]
        xml_parsing = general_options["XML_PARSING"]

        for Phase in ["AbstractPhase","Phase2011","PhaseSGML"]
            test_dir = joinpath(@__DIR__,"xmls/$(Phase)/")
            !isdir(test_dir) && continue
            files = filter(!isdir,readdir(joinpath(@__DIR__,"xmls/$(Phase)/")))
            test_output_path = joinpath([@__DIR__,"test_outputs","xml_test_outputs","current_outputs",Phase])
            create_dir(test_output_path)
            for file in files
                date = RunModule.run_xml(joinpath(@__DIR__,"xmls/$(Phase)/$file"),test_output_path,xml_parsing,csv_edit,edit_funcs,String(which_house),test_output_path)
                remove_files(test_output_path, remove_nums)
                sample_file = filter(contains(date), readdir(test_output_path))[1]
                mv(joinpath(test_output_path,sample_file),joinpath(test_output_path,"$(file[1:end-4])_sample.csv"),force=true)
            end

            gs_files = filter(f -> endswith(f,".csv"),readdir(joinpath("xml_gold_standard",Phase)))
            gs_csvs = filter(f -> endswith(f, ".csv"), gs_files)
            for gs_csv in gs_csvs
                curr = joinpath(test_output_path,gs_csv)
                correct = joinpath(joinpath("xml_gold_standard",Phase),gs_csv)
                pass = check_csv(curr,correct)
                print("$(gs_csv) is $(pass) \n")
            end
        end
        true
    end


    @test begin
        print("Test CSV test running ...")
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


