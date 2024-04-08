union!(LOAD_PATH, ["/home/eve/Desktop/Parlinfo_text_project/Scraper.jl/src"])
using CSV,DataFrames
using utils
using write_utils

function edit_row(row)
    row = edit_out_time_content_row(row)
    return row
end

function edit_out_time_content_row(row)
    content = row[end-1]
    new_content = edit_out_time_content(content)
    new_row = vcat(row[1:end-2],[new_content[1]],[row[end]],[new_content[2],new_content[3]])
    @show new_row
    return new_row
end

function edit_out_time_content(cell)
    pattern = r"\(\d{2}:\d{2}\):"
    match_ = match(pattern,cell)
    if match_ == nothing
        return [cell,"N/A","N/A"]
    else
        match_ = match_.match
        split_cell = split(cell,match_)
        return [split_cell[2],split_cell[1],match_]
    end
end
 

function process_csv(fn)
    csvfile = CSV.File(fn)
    fn = "question_to_answers_edited.csv"
    row_no = 0
    open(fn, "w") do io
        write_row_to_io(io,["question_flag","answer_flag","interjection_flag","name","name.id","electorate","party","content","path","content_1","content_2"])
        for row in eachrow(csvfile)
            #            println(io,row)
            if row_no > 1
                row_ = @. collect(row)
                row = row_[1]
                row = edit_row(row)
                @show row
                write_row_to_io(io,row)
            end
            row_no += 1
        end
    end
end

function edit_()
    fn = "question_to_answers_1.csv"
    process_csv(fn)
end
