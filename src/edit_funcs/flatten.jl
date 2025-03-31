#"""Not used as the edge case does not work"""
#function change_quote_to_answer(row,prev_row,header_to_num)
#    prev_content = prev_row[header_to_num[:content]]
#    if (occursin('ask',prev_content) && occursin('upon notice',prev_content)) || occursin('The answers to the honorable members questions are as follow',prev_content)
#        row[header_to_num[:answer_flat]] = 1
#    end
#    return row
#end

function flatten(step1fn,::Type{<:AbstractEditPhase})
    csvfilestep1 = CSV.File(step1fn)
    headers_ = copy(propertynames(csvfilestep1))
    header_to_num = edit_set_up(headers_)

    rows = eachrow(csvfilestep1)
    row_index = 1
    is_written = Dict(number => false for number in 1:length(rows))
    partstep2fn = split(step1fn,"_")[1]
    step2fn = "$(partstep2fn)_edit_step2.csv"
    name_pos = header_to_num[:name]
    content_pos = header_to_num[:content]
    id_pos = header_to_num[Symbol("name.id")]

    open(step2fn, "w") do io
        write_row_to_io(io,string.(headers_))
        prev_talker = "None"
        prev_id = "None"
        for row in rows
            if !is_written[row_index]
                if !is_stage_direction(row,header_to_num) && row_index < length(rows)
                    row_ = @. collect(row)
                    row = row_[1]
                    talker = row[name_pos]
                    id = row[id_pos]
                    if talker != "N/A"
                        prev_talker = talker
                        if id != "N/A"
                            prev_id = id
                        end
                    end
                    if row_index > 1                
                        prev_row = get_row(rows, row_index-1)
                        if :quote_flag in keys(header_to_num)
                            if row[header_to_num[:speech_flag]] == 1 && prev_row[header_to_num[:quote_flag]] == 1
                                row[name_pos] = prev_talker
                                row[id_pos] = prev_id 
                            end
                        end
                    end

                    row_content = row[content_pos]
                    children_content,is_written = find_all_child_speeches(row_index,rows,header_to_num,is_written)
                    row[content_pos] = row_content*" $children_content"
                else
                    row_ = @. collect(row)
                    row = row_[1]
                end

                if :quote_flag in keys(header_to_num)

                    if row[header_to_num[:quote_flag]] == 1 && prev_talker != "None"
                        row[name_pos] = prev_talker
                        row[id_pos] = prev_id
                    end
                end

                write_row_to_io(io,row)
            end
            row_index += 1
        end
    end
    return step2fn
end


"""
function find_all_child_speeches(row_no,rows,header_to_num,is_written)

Find all the speeches that belong to a single talker 
"""
function find_all_child_speeches(row_no,rows,header_to_num,is_written)
    #debug
    #    content_pos = header_to_num[:content]
    #    row = @. collect(rows[row_no])[1]
    #    log = false
    #    if occursin("On behalf of the Standing Committee on Petitions",row[content_pos])
    #        log = true
    #    end

    content = ""
    while !(stop_before_next_talker(row_no+1,rows,header_to_num,log)) && (row_no < length(rows))
        row = get_row(rows,row_no + 1)
        content_ = row[header_to_num[:content]]
        content *= " $content_"
        row_no += 1
        is_written[row_no] = true
        if row_no == length(rows)
            return content,is_written
        end
    end
    return content,is_written
end

function get_row(rows, row_no)
    row = rows[row_no]
    row_ = @. collect(row)
    return row_[1]
end

function equiv(current_row,next_row,header_to_num)
    function change_flag(flags)
        if flags[header_to_num[:quote_flag]] == 1
            flags[header_to_num[:quote_flag]] = 0
            flags[header_to_num[:speech_flag]] = 1
            return flags
        end
        return flags
    end
 
    flag_indices, current_flags = find_all_flags(current_row,header_to_num)
    flag_indices, next_flags = find_all_flags(next_row,header_to_num)
    if false
        current_flags = change_flag(current_flags)
        next_flags = change_flag(next_flags)
    end
    return current_flags == next_flags
end

function stop_before_next_talker(row_no,rows,header_to_num,log)
    if is_stage_direction(rows[row_no],header_to_num)
        return true
    else
        next_row = get_row(rows,row_no)

        name_pos = header_to_num[:name]
        if next_row[name_pos] != "N/A"
            return true
        else
           current_row = get_row(rows,row_no - 1)
           return !(equiv(current_row,next_row,header_to_num))
        end 
    end
    return false
end


"""get all flags except chamber flag"""
function find_all_flags(row,header_to_num)
 #   all_flags = [process_flag(row[header_to_num[k]]) for k in keys(header_to_num) if (occursin("flag",string(k)) && !(occursin("chamber",string(k))))]
    flag_indices = sort([header_to_num[k] for k in keys(header_to_num) if (occursin("flag",string(k)) && !(occursin("chamber",string(k))))])
    all_flags = [process_flag(row[f]) for f in flag_indices]
    return flag_indices,all_flags
end 

function is_stage_direction(row,header_to_num)
    row_ = @. collect(row)
    row = row_[1]
    flag_indices, all_flags = find_all_flags(row,header_to_num)
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


