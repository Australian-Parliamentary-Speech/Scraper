function re(input_fn,output_fn,::Type{<:AbstractEditPhase})
    csvfile = CSV.File(input_fn)
    headers_ = copy(propertynames(csvfile))
    header_to_num = edit_set_up(headers_)
    rows = eachrow(csvfile)
  
    open(output_fn, "w") do io
        write_row_to_io(io,string.(headers_))
        for row in rows
            row_ = @. collect(row)
            row = row_[1]
            row = edit_row(row,header_to_num)
            content = row[header_to_num[:content]]
            if content != ""
                write_row_to_io(io,row)
            end
        end
    end
end

function edit_row(row,header_to_num)
    row = remove_the_speaker(row,header_to_num)
    row = delete_semicolon(row,header_to_num)
    row = edit_interjections(row,header_to_num)
    row = delete_talker_from_content(row,header_to_num)
    row = find_speaker_content(row,header_to_num)
    row = remove_bits(row,header_to_num)
    return row
end

function find_speaker_content(row,header_to_num)
    content = row[header_to_num[:content]]
    speaker = match(r"^The DEPUTY SPEAKER \([^)]+\):",content)
    if !isnothing(speaker)
        speaker = speaker.match
        row[header_to_num[:name]] = clean_text(speaker)
        content = replace_known_beginning(content,speaker)
        row[header_to_num[:content]] = content
    end
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



function has_letters(s::AbstractString)
    return occursin(r"[a-zA-Z]", s)
end

function edit_interjections(row,header_to_num)
    content = row[header_to_num[:content]]
    if content != "N/A"
        m = match(r"[iI]nterjecting", content)
        if m != nothing && length(split(content," "))<5
            split_content = split(content,m.match)
            talker = split_content[1]
            row[header_to_num[:name]] = clean_text(talker)
       end
    elseif content == "N/A"
        talker = row[header_to_num[:name]]
        m = match(r"[iI]nterjecting", talker)
        if m != nothing 
            split_content = split(talker,m.match)
            row[header_to_num[:name]] = split_content[1]
            row[header_to_num[:content]] = clean_text(talker)
        end
    end
    return row
end

function replace_known_beginning(s,beginning)
    cell = try
        Regex("^\\Q$(beginning)\\E:?")
    catch e
        @show beginning
        @show e
    end

    regs = [cell, r"The SPEAKER:",r"Mr SPEAKER"]
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

