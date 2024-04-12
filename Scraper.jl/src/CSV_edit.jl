union!(LOAD_PATH, ["/home/eve/Desktop/Parlinfo_text_project/Scraper.jl/src"])
using CSV,DataFrames
using utils
using write_utils
using edit_utils


function edit_set_up(headers)
    return Dict(zip(headers[1:end-2],collect(1:length(headers)-2))) 
end

function test_replace()
    content = "Mr Bandt: The point of order is on relevance. The question was about the phase out of coal and whether that would be something that Australia will join in the communique at this week's summit, not about other matters."
    replace_known_beginning(content,"Mr Bandt")
end

function edit_row(row,run_params,header_to_num,row_no)
    name_pos = header_to_num["name"]
    row = edit_out_time_content_row(row,header_to_num)
    if row[name_pos] == "N/A"
        row[name_pos:name_pos+3] = run_params.previous_talker
    end
    row = remove_the_speaker(row,header_to_num)
    row = delete_comma(row,header_to_num)
    row = edit_interjections(row,header_to_num)
    row = delete_talker_from_content(row,header_to_num)  
    return row
end


function process_csv(fn)
    headers = ["question_flag","answer_flag","interjection_flag","name","name.id","electorate","party","content","path","content_1","content_2"]
    header_to_num = edit_set_up(headers)
    csvfile = CSV.File(fn)
    fn = "question_to_answers_edited.csv"
    row_no = 0
    run_params = Edit_Params([" "])
    open(fn, "w") do io
        write_row_to_io(io,headers)
        for row in eachrow(csvfile)
            row_ = @. collect(row)
            row = row_[1]
            name_pos = header_to_num["name"]
            talker = row[name_pos]
            if talker != "N/A"
                run_params.previous_talker = row[name_pos:name_pos+3]
            end
            row = edit_row(row,run_params,header_to_num,row_no)
            write_row_to_io(io,row)
            row_no += 1
        end
    end
end

function edit_()
    fn = "question_to_answers_1.csv"
    process_csv(fn)
end
