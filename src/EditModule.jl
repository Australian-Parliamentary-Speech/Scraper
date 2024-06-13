module EditModule
using CSV,DataFrames
using ..NodeModule
using ..Utils
export edit_csv

mutable struct Edit_Params
    previous_talker::Vector{String}
    row_no::Int64
end


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
    run_params = Edit_Params([" "],1)
    open("$(fn[1:end-4])_edit.csv", "w") do io
        @show headers_
        write_row_to_io(io,string.(headers_))
        for row in eachrow(csvfile)
            @show row
            row_ = @. collect(row)
            row = row_[1]
            @show row
            name_pos = header_to_num[:name]
            talker = row[name_pos]
            @show talker
            if talker != "N/A"
                run_params.previous_talker = row[name_pos:name_pos+5]
            end
            row = edit_row(row,run_params,header_to_num)
            write_row_to_io(io,row)
            run_params.row_no += 1
        end
    end
end

function adopt_last_talker(row,run_params,header_to_num)
    function process_flag(flag)
        if typeof(flag) <: Int
            return flag
        else
            return parse(Int,flag)
        end
    end
    name_pos = header_to_num[:name]
    all_flags = [process_flag(row[header_to_num[k]]) for k in keys(header_to_num) if (occursin("flag",string(k)) && !(occursin("chamber",string(k))))]
    if row[name_pos] == "N/A"
        if !(all(==(0), all_flags)) && (length(run_params.previous_talker) > 1)
            row[name_pos:name_pos+5] = run_params.previous_talker
        end  
    end
    return row
end
 
function edit_row(row,run_params,header_to_num)
    row = edit_out_time_content_row(row,header_to_num)
    row = adopt_last_talker(row,run_params,header_to_num)
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
