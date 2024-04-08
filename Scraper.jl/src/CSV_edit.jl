union!(LOAD_PATH, ["/home/eve/Desktop/Parlinfo_text_project/Scraper.jl/src"])
using CSV,DataFrames
using utils
using write_utils

function edit_row(row)
    @show row
    row = replace_empty_string(row)
    return row
end

function process_csv(fn)
    csvfile = CSV.File(fn)
    fn = "question_to_answers_edited.csv"
    open(fn, "w") do io
        println(io,["question_flag","answer_flag","interjection_flag","name","name.id","electorate","party","content","path"])
        for row in eachrow(csvfile)
#            println(io,row)
            row_ = @. collect(row)
            row = row_[1]
            row = edit_row(row)
            write_row_to_io(io,row)
        end
    end
end

function edit_()
    fn = "question_to_answers_1.csv"
    process_csv(fn)
end
