function fuzzy_bar_match(gs_content, sample_content,test_setup)
    fuzzy_bars = sample_bars(gs_content,test_setup)
    return !(false in @. occursin(fuzzy_bars, sample_content))
end

function count_words(content)
    sentences = split(content, r"[[:punct:]]+")
    numbers = @. count(w -> occursin(r"^[A-Za-z]+$", w), split(sentences))
    if maximum(numbers) > 1
        return minimum([number for number in numbers if number>1])
    else
        return 1
    end
end

function sample_bars(gs_content::String,test_setup)
    fuzzy_bar_length, fuzzy_interval = test_setup.fuzzy_search
    bar_length = minimum([fuzzy_bar_length, count_words(gs_content)])
    if bar_length > 1
        pattern = Regex("\\b\\w+(?:\\s+\\w+){$(bar_length-1)}")
    else
        pattern = pattern = Regex("[A-Za-z]{$bar_length}")
    end
    matches = collect(eachmatch(pattern, gs_content))
    @assert !isempty(matches) "Failure creating bars from $gs_content"
    chosen = randperm(length(matches))[1:min(fuzzy_interval, length(matches))]
    return [matches[i].match for i in chosen]
end

function gs_sample_content_match(gs_content,sample_content,test_setup)
    if test_setup.which_test == :exact
        return sample_content == gs_content
    elseif test_setup.which_test == :fuzzy
        return fuzzy_bar_match(gs_content,sample_content,test_setup)
    end
end

function similarity_csv(gs_csv,sample_csv,test_setup,test_output_path)
    sample_csvfile = CSV.File(sample_csv)
    gs_rows = eachrow(CSV.File(gs_csv))
    headers = copy(propertynames(sample_csvfile)) 
    sample_rows = eachrow(sample_csvfile)
    header_to_num = edit_set_up(headers)
    success = 0
    fn_found = joinpath(test_output_path,"found_similarity_output_$(basename(gs_csv))")
    found_lines = []
    fn_missing = joinpath(test_output_path,"missing_output_$(basename(gs_csv))")
    missing_lines = []
    for gs_row in gs_rows
        gs_row = get_row(gs_row)
        equiv = compare_row(sample_rows,gs_row,header_to_num,test_setup) 
            if ismissing(equiv)
                push!(missing_lines,"\"$(gs_row[header_to_num[:content]])\"")
            else
                e,row,i = equiv
                if e
                    success += 1
                else
                    gs_content = gs_row[header_to_num[:content]]
                    line = [i, gs_content]

                    push!(found_lines,edit_row(line))
                end
            end
        end
        write(fn_found, join(found_lines, "\n") * "\n")
        write(fn_missing, join(missing_lines, "\n") * "\n")
    return success/length(gs_rows)
end

function compare_row(sample_rows, gs_row, header_to_num,test_setup)
   function equiv(row,gs_row,skip_cols)
        skip_nums = [header_to_num[col] for col in skip_cols]
        for i in 1:length(row)
            if !(i in skip_nums)
                if row[i] != gs_row[i]
                    return false, row, i
                end
            end
        end
        return true, row, length(row)
    end
    skip_cols = test_setup.skip_cols
    gs_content = gs_row[header_to_num[:content]]
    for i in 1:length(sample_rows)
        row = get_row(sample_rows[i])
        sample_content = row[header_to_num[:content]]
        if gs_sample_content_match(gs_content,sample_content,test_setup)
            return equiv(row,gs_row,skip_cols)
        end
    end
    return missing
end


