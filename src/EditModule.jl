module EditModule
using CSV,DataFrames
using ..NodeModule
using ..Utils
export edit_csv


function edit_set_up(headers)
    return Dict(zip(headers,collect(1:length(headers)))) 
end

function edit_csv(fn,::Type{<:AbstractPhase})
    csvfile = CSV.File(fn)
    headers_ = copy(propertynames(csvfile))
    header_to_num = edit_set_up(headers_)
    #any additional headers needed
    for header in [:Speaker,:Time]
        push!(headers_,header)
    end
    is_written = Dict(number => false for number in 1:length(eachrow(csvfile)))
    row_index = 1
    rows = eachrow(csvfile)
    open("$(fn[1:end-4])_edit.csv", "w") do io
        write_row_to_io(io,string.(headers_))
        for row in rows
            if !is_written[row_index]
                row_ = @. collect(row)
                row = row_[1]
                name_pos = header_to_num[:name]
                content_pos = header_to_num[:content]
                talker = row[name_pos]
                row_content = row[content_pos]
                children_content,is_written = find_all_child_speeches(row_index,rows,header_to_num,is_written)
                row[content_pos] = row_content*children_content
                row = edit_row(row,header_to_num)
                write_row_to_io(io,row)
            end
            row_index += 1
        end
    end
end

function find_all_child_speeches(row_no,rows,header_to_num,is_written)
    content = ""
    while !stop_before_next_talker(row_no,rows,header_to_num)
        row = rows[row_no+1]
        row_ = @. collect(row)
        row = row_[1]
        content_ = row[header_to_num[:content]]
        content *= content_
        row_no += 1
        is_written[row_no] = true
    end
    return content,is_written
end

function stop_before_next_talker(row_no,rows,header_to_num)
    if is_stage_direction(rows[row_no],header_to_num) || row_no == length(rows)
        return true
    else
        next_row = rows[row_no + 1]
        next_row_ = @. collect(next_row)
        next_row = next_row_[1]
        name_pos = header_to_num[:name]

        if next_row[name_pos] != "N/A"
            return true
        end 
    end
    return false
end

function is_stage_direction(row,header_to_num)
    row_ = @. collect(row)
    row = row_[1] 
    all_flags = [process_flag(row[header_to_num[k]]) for k in keys(header_to_num) if (occursin("flag",string(k)) && !(occursin("chamber",string(k))))]
    if all(==(0), all_flags)
        return true
    end  
    return false 
end

function process_flag(flag)
    if typeof(flag) <: Int
        return flag
    else
        return parse(Int,flag)
    end
end

#function check_adopt_last_talker(row,header_to_num,talker_tree)
#    function process_flag(flag)
#        if typeof(flag) <: Int
#            return flag
#        else
#            return parse(Int,flag)
#        end
#    end
#    name_pos = header_to_num[:name]
#    all_flags = [process_flag(row[header_to_num[k]]) for k in keys(header_to_num) if (occursin("flag",string(k)) && !(occursin("chamber",string(k))))]
#    if row[name_pos] == "N/A"
#        if !(all(==(0), all_flags)) && (length(talker_tree) > 1)
#            return true
#        end  
#    end
#    return false
#end
 
function edit_row(row,header_to_num)
    row = edit_out_time_content_row(row,header_to_num)
    row = remove_the_speaker(row,header_to_num)
    row = delete_semicolon(row,header_to_num)
    row = edit_interjections(row,header_to_num)
    row = delete_talker_from_content(row,header_to_num) 
    return row
end


function remove_the_speaker(row,header_to_num)
    name_num = header_to_num[:name]
    pattern = r"\(The\s+SPEAKER\)"
    row[name_num] = replace(row[name_num], pattern => "")
#    if row[name_num] != test
#        @show test
#    end
    return row
end

function edit_out_time_content_row(row,header_to_num)
    content_num = header_to_num[:content]
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

function edit_interjections(row,header_to_num)
    content = row[header_to_num[:content]]
    if content != "N/A"
        m = match(r"[iI]nterjecting—", content)
        if m != nothing
            split_content = split(content,m.match)
            talker = split_content[1]
            row[header_to_num[:name]] = talker
        end
    end
    return row
end

function replace_known_beginning(s,beginning)
    regs = [Regex("^$(beginning):"),r"The SPEAKER:"]
    for reg in regs
        m = match(reg, s)
        if m !== nothing
            return replace(s, m.match => "")
        else
            continue
        end
    end
    return s
end

function delete_talker_from_content(row,header_to_num)
    talker = row[header_to_num[:name]]
    content = row[header_to_num[:content]]
    content = replace_known_beginning(content,talker)
    row[header_to_num[:content]] = content
    return row
end

function delete_semicolon(row,header_to_num)
    name = row[header_to_num[:name]]
    name = replace(name, ":" => "")
    row[header_to_num[:name]] = name
    return row
end


end
