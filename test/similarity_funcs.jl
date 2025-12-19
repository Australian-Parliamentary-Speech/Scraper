function fuzzy_bar_match(gs_cell, sample_cell,test_setup)
    fuzzy_bars = sample_bars(gs_cell,test_setup)
    for fuzzy_bar in fuzzy_bars        
        if !occursin(fuzzy_bar,sample_cell)
           return missing
        end
    end
    return content_distance(gs_cell,sample_cell)
end

function count_words(content)
    sentences = split(content, r"[[:punct:]]+")
    numbers = @. count(w -> occursin(r"^[A-Za-z]+$", w), split(sentences))
    if maximum(numbers) > 1
        return maximum([number for number in numbers if number>1])
    else
        return 1
    end
end

function sample_bars(gs_content,test_setup)
    fuzzy_bar_length, fuzzy_interval = test_setup.fuzzy_search
    bar_length = minimum([fuzzy_bar_length, count_words(gs_content)])
    if bar_length > 1
        pattern = Regex("\\b\\w+(?:\\s+\\w+){$(bar_length-1)}")
    else
        pattern =  r"(?<= )([A-Za-z]+)(?= )"
    end
    matches = collect(eachmatch(pattern, gs_content))
    if isempty(matches)
        return [gs_content]
    else
        chosen = [matches[i].match for i in 1:fuzzy_interval:length(matches)]
        return chosen
    end
end

function gs_sample_content_match(gs_content,sample_content,test_setup)
    if test_setup.which_test == :exact
        return content_distance_score(gs_content,sample_content)
    elseif test_setup.which_test == :fuzzy
        return fuzzy_bar_match(gs_content,sample_content,test_setup)
    end
end

function Date_to_Dict(gold_standard_csvs)
    date_to_d = Dict()
    for gs in gold_standard_csvs
        date = find_date(gs)
        gs_df = CSV.read(gs, DataFrame)
        gs_id_col = filter(!=("N/A"),gs_df[!,Symbol("name.id")])
        MP_to_count_ = MP_to_count(gs_id_col)
        date_to_d[date] = MP_to_count_
    end
    return date_to_d
end

function MP_to_count(col)
    MP_to_count_ = Dict()
    for id in col
        MP_to_count_[id] = get(MP_to_count_,id,0) + 1
    end
    return MP_to_count_
end

function Date_to_ImpftDict(date_to_list)
    date_to_impfct_namedict = Dict()
    for (date,list) in date_to_list
        id_to_count = MP_to_count(list)
        date_to_impfct_namedict[date] = id_to_count
    end
    return date_to_impfct_namedict
end

function MPs_not_perfect(dates,gs_test_output_dir)
    date_to_list = Dict()
    for date in dates
        sim_csv = filter(f -> occursin("similarity", f) && occursin(date, f), readdir(gs_test_output_dir))[1]
        miss_csv = filter(f -> occursin("missing", f) && occursin(date, f), readdir(gs_test_output_dir))[1]
 
        sim_df = CSV.read(joinpath(gs_test_output_dir, sim_csv), DataFrame,header=false)
        if sim_df == DataFrame()
            sim_list = []
        else
            sim_list =filter(!=("N/A"), sim_df[:,1])
        end

        miss_df = CSV.read(joinpath(gs_test_output_dir, miss_csv), DataFrame,header=false) 
#        if isempty(miss_df)
        if miss_df == DataFrame()
            miss_list = []
        else
            miss_list = filter(!=("N/A"), miss_df[:,1])
        end
        list = vcat(sim_list, miss_list)
        date_to_list[date] = list
    end
    return date_to_list
end

function all_GS_dates(gold_standard_csvs)
    dates = String[]
    for gs_csv in gold_standard_csvs
        gs_name = basename(gs_csv)
        push!(dates,find_date(gs_name)) 
    end
    return dates
end

function similarity_csv(gs_csv,sample_csv,test_setup,test_output_path)
    sample_csvfile = CSV.File(sample_csv)
    gs_rows = eachrow(CSV.File(gs_csv))
    headers = copy(propertynames(sample_csvfile)) 
    sample_rows = eachrow(sample_csvfile)
    header_to_num = edit_set_up(headers)
    total_score = 0
    fn_found = joinpath(test_output_path,"found_similarity_output_$(basename(gs_csv))")
    found_lines = []
    fn_missing = joinpath(test_output_path,"missing_output_$(basename(gs_csv))")
    missing_lines = []

    for gs_row in gs_rows
        gs_row = get_row(gs_row)
        score, failed_indices = compare_row(sample_rows,gs_row,header_to_num,test_setup) 
        gs_content = gs_row[header_to_num[:content]]
        gs_speaker = gs_row[header_to_num[Symbol("name.id")]]

        if failed_indices == "missing"
            line =[gs_speaker,gs_content] 
            push!(missing_lines,edit_row(line))
        else
            if isempty(failed_indices)
                total_score += score
            else
                total_score += score
                line = [gs_speaker,gs_content,failed_indices...]
                push!(found_lines,edit_row(line))
            end
        end
    end
    write(fn_found, join(found_lines, "\n") * "\n")
    write(fn_missing, join(missing_lines, "\n") * "\n")
    return total_score/length(gs_rows)
end

function content_distance(gs_cell,sample_cell)
    function cell_to_words(sentence)
        words = split(sentence, r"\W+") 
        words = filter(!isempty, words)
        wordset = Set(words)
        return wordset
    end
 
    if gs_cell == sample_cell
        return 0
    else
        gs_words = cell_to_words(gs_cell)
        sample_words = cell_to_words(sample_cell)
        measure = (length(setdiff(gs_words,sample_words)) + length(setdiff(sample_words,gs_words)))/2
        return measure
    end
end

function content_distance_score(gs_cell,sample_cell)
    if gs_cell == sample_cell
        return 1
    else
        return 0
    end
end

function cell_score(sample_row,gs_row,skip_nums,content_num,i)
    if i in skip_nums
        return 1,"skipped"
    end
    gs_cell = gs_row[i]

    sample_cell = sample_row[i]
    if i == content_num
        score = content_distance_score(gs_cell,sample_cell)
        @assert score <= 1
        if score != 1
            #for testing
            if false
                if length(collect(split(sample_cell))) < 300
                    @show gs_cell
                    print("\n")
                    @show sample_cell
                    print("\n")
                end
            end
            return score, "failed"
        else
            return score, "passed"
        end
    else
        if gs_cell == sample_cell
            return 1,"passed"
        else
            return 0,"failed"
        end
    end
end

function find_correct_row(sample_rows,content_num,gs_content,test_setup)
    the_correct_row = (0,1e5)
    for i in 1:length(sample_rows)
        sample_row = get_row(sample_rows[i])
        sample_content = sample_row[content_num]
        gs_sample_distance = gs_sample_content_match(gs_content,sample_content,test_setup)
        if !ismissing(gs_sample_distance)
            if gs_sample_distance < the_correct_row[2]
                the_correct_row = (i,gs_sample_distance)
                # to turn off the selection after iteration of the whole CSV
                if false
                    return the_correct_row
                end
           end
        end
    end
    return the_correct_row
end


function compare_row(sample_rows, gs_row, header_to_num,test_setup)
    skip_cols = test_setup.skip_cols
    skip_nums = [get(header_to_num,col,"N/A") for col in skip_cols]
    content_num = header_to_num[:content]
    gs_content = gs_row[content_num]
    if gs_content == "N/A"
        return 1,[]
    end
    
    the_correct_row = find_correct_row(sample_rows,content_num,gs_content,test_setup)
    if the_correct_row[1] != 0
        sample_row = get_row(sample_rows[the_correct_row[1]])
        row_score = 0
        failed_indices = []
        for j in 1:length(gs_row)
            c_score = cell_score(sample_row,gs_row,skip_nums,content_num,j)
            row_score += c_score[1]
            if c_score[2] == "failed"
                push!(failed_indices,j)
            end
        end
        final_score = row_score/length(gs_row)
        @assert final_score <= 1 "Final score for this row is $final_score"
        return final_score,failed_indices
    else
        return 0, "missing"
    end
end


