module edit_utils
using AndExport

@xport mutable struct Edit_Params
    previous_talker::Vector{String}
end


@xport function remove_the_speaker(row,header_to_num)
    name_num = header_to_num["name"]
    pattern = r"\(The\s+SPEAKER\)"
    row[name_num] = replace(row[name_num], pattern => "")
    return row
end

@xport function edit_out_time_content_row(row,header_to_num)
    content_num = header_to_num["content"]
    content = row[content_num]
    new_content = edit_out_time_content(content)
    row[content_num] = new_content[1]
    new_row = vcat(row,[new_content[2],new_content[3]])
    return new_row
end

@xport function edit_out_time_content(cell)
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
 
@xport function has_letters(s::AbstractString)
    return occursin(r"[a-zA-Z]", s)
end

@xport function edit_interjections(row,header_to_num)
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

@xport function replace_known_beginning(s,beginning)
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

@xport function delete_talker_from_content(row,header_to_num)
    talker = row[header_to_num["name"]]
    content = row[header_to_num["content"]]
    content = replace_known_beginning(content,talker)
    row[header_to_num["content"]] = content
    return row
end

@xport function delete_comma(row,header_to_num)
    name = row[header_to_num["name"]]
    name = replace(name, ":" => "")
    row[header_to_num["name"]] = name
    return row
end


end
