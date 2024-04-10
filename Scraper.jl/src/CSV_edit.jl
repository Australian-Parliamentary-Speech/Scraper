union!(LOAD_PATH, ["/home/eve/Desktop/Parlinfo_text_project/Scraper.jl/src"])
using CSV,DataFrames
using utils
using write_utils


mutable struct Edit_Params
    previous_talker::Vector{String}
end

function edit_out_time_content_row(row,header_to_num)
    content_num = header_to_num["content"]
    content = row[content_num]
    new_content = edit_out_time_content(content)
    row[content_num] = new_content[1]
    new_row = vcat(row,[new_content[2],new_content[3]])
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
 
function has_letters(s::AbstractString)
    return occursin(r"[a-zA-Z]", s)
end

function edit_set_up(headers)
    return Dict(zip(headers[1:end-2],collect(1:length(headers)-2))) 
end

function edit_interjections(row,header_to_num)
    content = row[header_to_num["content"]]
    if content != "N/A"
        m = match(r"[iI]nterjecting—", content)
        if m != nothing
            split_content = split(content,m.match)
            talker = split_content[1]
            row[header_to_num["name"]] = talker
        end
    end
    return row
end

function replace_known_beginning(s,beginning)
    regs = [Regex("^$(beginning):"),r"The SPEAKER:"]
    for reg in regs
        m = match(reg, s)
        if m !== nothing
            @show m
            return replace(s, m.match => "")
        else
            continue
        end
    end
    return s
end

function test_replace()
    content = "Mr Bandt: The point of order is on relevance. The question was about the phase out of coal and whether that would be something that Australia will join in the communique at this week's summit, not about other matters."
    replace_known_beginning(content,"Mr Bandt")
end

function delete_talker_from_content(row,header_to_num)
    talker = row[header_to_num["name"]]
    content = row[header_to_num["content"]]
    content = replace_known_beginning(content,talker)
    row[header_to_num["content"]] = content
    return row
end

function delete_comma(row,header_to_num)
    name = row[header_to_num["name"]]
    name = replace(name, ":" => "")
    row[header_to_num["name"]] = name
    return row
end

function edit_row(row,run_params,header_to_num,row_no)
    name_pos = header_to_num["name"]
    row = edit_out_time_content_row(row,header_to_num)
    if row[name_pos] == "N/A"
        row[name_pos:name_pos+3] = run_params.previous_talker
    end
    row = delete_comma(row,header_to_num)
    edit_interjections(row,header_to_num)
    delete_talker_from_content(row,header_to_num)  
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
            #            println(io,row)
            if row_no > 1
                row_ = @. collect(row)
                row = row_[1]
                name_pos = header_to_num["name"]
                talker = row[name_pos]
                if talker != "N/A"
                    run_params.previous_talker = row[name_pos:name_pos+3]
                end
                row = edit_row(row,run_params,header_to_num,row_no)
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
