union!(LOAD_PATH, ["/home/eve/Desktop/Parlinfo_text_project/Scraper.jl/src"])
using CSV,DataFrames
using utils
using write_utils
using edit_utils
using BetterInputFiles


function edit_set_up(headers)
    return Dict(zip(headers[1:end-2],collect(1:length(headers)-2))) 
end

function test_replace()
    content = "Mr Bandt: The point of order is on relevance. The question was about the phase out of coal and whether that would be something that Australia will join in the communique at this week's summit, not about other matters."
    replace_known_beginning(content,"Mr Bandt")
end

function edit_row(row,run_params,header_to_num,row_no,options)
    name_pos = header_to_num["name"]
    row = edit_out_time_content_row(row,header_to_num)
    if options["ADOPT_PREVIOUS_SPEAKER"] 
        if row[name_pos] == "N/A"
            row[name_pos:name_pos+3] = run_params.previous_talker
        end
    end
    if options["REMOVE_THE_SPEAKER"] 
        row = remove_the_speaker(row,header_to_num)
    end
    if options["DELETE_SEMICOLON"]
        row = delete_semicolon(row,header_to_num)
    end
    if options["EDIT_INTERJECTIONS"]
        row = edit_interjections(row,header_to_num)
    end
    if options["DELETE_TALKER_FROM_CONTENT"]
        row = delete_talker_from_content(row,header_to_num) 
    end
    return row
end

function set_up_edit_options(fn)
    input = setup_input("edit_set_up.toml", true)
    if occursin("question",fn)
        options = input["QUESTION_TIME_OPTION"]
    elseif occursin("speech",fn)
        options = input["SPEECH_OPTION"]
    end
    return options
end


function process_csv(fn)
    headers = ["question_flag","answer_flag","interjection_flag","speech_flag","others_flag","name","name.id","electorate","party","content","path","content_1","content_2"]
    header_to_num = edit_set_up(headers)
    csvfile = CSV.File(fn)
    row_no = 0
    run_params = Edit_Params([" "])
    open("$(fn)_edit.csv", "w") do io
        options = set_up_edit_options(fn)
        @show headers
        write_row_to_io(io,headers)
        for row in eachrow(csvfile)
            row_ = @. collect(row)
            row = row_[1]
            name_pos = header_to_num["name"]
            talker = row[name_pos]
            if talker != "N/A"
                run_params.previous_talker = row[name_pos:name_pos+3]
            end
            row = edit_row(row,run_params,header_to_num,row_no,options)
            write_row_to_io(io,row)
            row_no += 1
        end
    end
end

function edit_()
    for whichchamber in ["fedchamb","chamber"]
        for fn in ["csvs/$(whichchamber)question_to_answers_1.csv","csvs/$(whichchamber)speeches.csv"]
            if fn != "csvs/fedchambquestion_to_answers_1.csv"
                process_csv(fn)
            end
        end
    end
end
