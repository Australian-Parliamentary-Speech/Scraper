module EditModule
using CSV,DataFrames
using ..NodeModule
using ..Utils
export edit_csv

"""
edit_set_up(headers)

Sets up a dictionary mapping each element in `headers` to its corresponding index.

Inputs:
- `headers`: An array of header names or keys.

Returns:
- A dictionary where each header in `headers` is mapped to its index position.
"""
function edit_set_up(headers)
    return Dict(zip(headers,collect(1:length(headers)))) 
end

"""
edit_csv(fn, ::Type{<:AbstractPhase})

Two steps are implemented here. The first step does mostly regular expression processing. The second step collapses some of the N/As to the previous talker.
"""
function edit_csv(fn,::Type{<:AbstractPhase})
    csvfile = CSV.File(fn)
    headers_ = copy(propertynames(csvfile))
    header_to_num = edit_set_up(headers_)
    #any additional headers needed
    for header in [:Speaker,:Time]
        push!(headers_,header)
    end
    rows = eachrow(csvfile)
    #name change
    step1fn = "$(fn[1:end-4])_edit_step1.csv"
    open(step1fn, "w") do io
        write_row_to_io(io,string.(headers_))
        for row in rows
            row_ = @. collect(row)
            row = row_[1]
            row = edit_row(row,header_to_num)
            write_row_to_io(io,row)
        end
    end

    csvfilestep1 = CSV.File(step1fn)
    rows = eachrow(csvfilestep1)
    row_index = 1
    is_written = Dict(number => false for number in 1:length(eachrow(csvfile)))
    open("$(fn[1:end-4])_edit_step2.csv", "w") do io
        write_row_to_io(io,string.(headers_))
        for row in rows
            if !is_written[row_index]
                if !is_stage_direction(row,header_to_num)
                    row_ = @. collect(row)
                    row = row_[1]

                    name_pos = header_to_num[:name]
                    content_pos = header_to_num[:content]
                    talker = row[name_pos]
                    row_content = row[content_pos]
                    children_content,is_written = find_all_child_speeches(row_index,rows,header_to_num,is_written)
                    row[content_pos] = row_content*children_content
                else
                    row_ = @. collect(row)
                    row = row_[1]
                end
                write_row_to_io(io,row)

            end
            row_index += 1
        end
    end
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
    while row_no != length(rows)   
        @show row_no
        while !stop_before_next_talker(row_no+1,rows,header_to_num,log)         
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
    return content,is_written
end

function stop_before_next_talker(row_no,rows,header_to_num,log)
    if is_stage_direction(rows[row_no],header_to_num)

        @show row_no
#        row = rows[row_no]
#        row = @. collect(row)
#        @show row[1][header_to_num[:content]]
        return true
    else
        next_row = rows[row_no]
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
    #get all flags except chamber flag
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
    patterns = [r"\(The\s+SPEAKER\)",r"\(The\s+DEPUTY\s+SPEAKER\)"]
    for pattern in patterns
        row[name_num] = replace(row[name_num], pattern => "")
    end
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
    if isnothing(match_) 
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
        if m != nothing && length(split(content," "))<5
            split_content = split(content,m.match)
            talker = split_content[1]
            row[header_to_num[:name]] = talker
        end
    elseif content == "N/A"
        talker = row[header_to_num[:name]]
        m = match(r"[iI]nterjecting—", talker)
        if m != nothing 
            split_content = split(talker,m.match)
            row[header_to_num[:name]] = split_content[1]
            row[header_to_num[:content]] = talker
        end
 
 
    end

    return row
end

function replace_known_beginning(s,beginning)
    cell = try
        Regex("^$(beginning):")
    catch LoadError
        Regex("^$(beginning)):")
    end
    regs = [cell,r"The SPEAKER:"]
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
