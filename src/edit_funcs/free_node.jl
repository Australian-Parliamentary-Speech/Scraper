
function free_node(input_fn, output_fn,::Type{<:AbstractEditPhase})
    csvfile= CSV.File(input_fn)
    headers_ = copy(propertynames(csvfile))
    header_to_num = edit_set_up(headers_)
    rows = eachrow(csvfile)
    row_index = 1
    name_pos = header_to_num[:name]
    content_pos = header_to_num[:content]
    id_pos = header_to_num[Symbol("name.id")]

    open(output_fn, "w") do io
        write_row_to_io(io,string.(headers_))
        prev_talker = "None"
        prev_id = "None"
        prev_debate = "None"
        prev_subdebate = "None"
        for row in rows
            if !is_stage_direction(row,header_to_num) && row_index < length(rows)
                row_ = @. collect(row)
                row = row_[1]
                talker = row[name_pos]
                id = row[id_pos]
                debate, subdebate = row[header_to_num[:debateinfo]],row[header_to_num[:subdebateinfo]]
                if debate == prev_debate && subdebate == prev_subdebate
                    if cell_not_null(talker) 
                        prev_talker = talker
                        if id != "N/A"
                            prev_id = id
                        end
                    end
                    prev_row = get_row(rows, row_index-1)
                    row = free_node_op(row,prev_row,prev_talker,prev_id,header_to_num,talker)
                    row = speech_quote_speaker(row,prev_row,prev_talker,prev_id,header_to_num,talker)
 
                else
                    prev_talker = "None"
                end
                prev_debate = debate
                prev_subdebate = subdebate

            else
                row_ = @. collect(row)
                row = row_[1]
            end
            if row[name_pos] == "FREE NODE"
                row[name_pos] = "N/A"
            end
            write_row_to_io(io,row)
            row_index += 1
        end
    end
end

"""if it is free flowing, check if it is same debate and add it to the previous one"""
function free_node_op(row,prev_row,prev_talker,prev_id,header_to_num,talker)
    name_pos = header_to_num[:name]
    id_pos = header_to_num[Symbol("name.id")] 
    if talker == "FREE NODE" 
        if cell_not_null(prev_talker)
            row[name_pos] = prev_talker
            row[id_pos] = prev_id
        end
    end
    return row
end

function speech_quote_speaker(row,prev_row,prev_talker,prev_id,header_to_num,talker)
    name_pos = header_to_num[:name]
    id_pos = header_to_num[Symbol("name.id")]
    if :quote_flag in keys(header_to_num) 
        if row[header_to_num[:speech_flag]] == 1 && prev_row[header_to_num[:quote_flag]] == 1 && (!cell_not_null(talker))
            row[name_pos] = prev_talker
            row[id_pos] = prev_id
        elseif row[header_to_num[:quote_flag]] == 1 && cell_not_null(prev_talker) && (!cell_not_null(talker))
            row[name_pos] = prev_talker
            row[id_pos] = prev_id 
        end
    end
    return row
end

