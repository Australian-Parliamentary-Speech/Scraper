function fuzzy_bar_match(gs_cell, sample_cell,test_setup)
    fuzzy_bars = sample_bars(gs_cell,test_setup)
    if !(false in @. occursin(fuzzy_bars, sample_cell))
        return content_distance(gs_cell,sample_cell)
    else
        return false
    end
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

function sample_bars(gs_content::String,test_setup)
    fuzzy_bar_length, fuzzy_interval = test_setup.fuzzy_search
    bar_length = minimum([fuzzy_bar_length, count_words(gs_content)])
    if bar_length > 1
        pattern = Regex("\\b\\w+(?:\\s+\\w+){$(bar_length-1)}")
    else
        pattern = pattern = Regex("[A-Za-z]{$bar_length}")
    end
    matches = collect(eachmatch(pattern, gs_content))
    if isempty(matches)
        return [gs_content]
    else
        chosen = [matches[i].match for i in 1:5:length(matches)]
        return chosen
    end
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
    total_score = 0
    fn_found = joinpath(test_output_path,"found_similarity_output_$(basename(gs_csv))")
    found_lines = []
    fn_missing = joinpath(test_output_path,"missing_output_$(basename(gs_csv))")
    missing_lines = []

    for gs_row in gs_rows
        gs_row = get_row(gs_row)
        score, failed_indices = compare_row(sample_rows,gs_row,header_to_num,test_setup) 
        if failed_indices == "missing"
            push!(missing_lines,"\"$(gs_row[header_to_num[:content]])\"")
        else
            if isempty(failed_indices)
                total_score += score
            else
                total_score += score
                gs_content = gs_row[header_to_num[:content]]
                line = [gs_content,failed_indices...]
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
        return 1
    else
        gs_words = cell_to_words(gs_cell)
        sample_words = cell_to_words(sample_cell)
        measure = length(setdiff(gs_words,sample_words)) + length(setdiff(sample_words,gs_words))
        return measure
    end
end

function cell_score(sample_row,gs_row,skip_nums,content_num,i)
    if i in skip_nums
        return 0,"skipped"
    end
    gs_cell = gs_row[i]

    sample_cell = sample_row[i]
    if i == content_num
        score = content_distance(gs_cell,sample_cell)
        if score != 1
            @show gs_cell
            @show sample_cell
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


function compare_row(sample_rows, gs_row, header_to_num,test_setup)
    skip_cols = test_setup.skip_cols
    skip_nums = [header_to_num[col] for col in skip_cols]
    content_num = header_to_num[:content]

    the_correct_row = (0,0)
    gs_content = gs_row[content_num]
    if gs_content == "N/A"
        return 1,[]
    end

    for i in 1:length(sample_rows)
        sample_row = get_row(sample_rows[i])
        sample_content = sample_row[content_num]
        gs_sample_distance =  gs_sample_content_match(gs_content,sample_content,test_setup) 
        if gs_sample_distance != false 
            if gs_sample_distance > the_correct_row[2]
                the_correct_row = (i,gs_sample_distance)
            end
        end
    end

    if the_correct_row != (0,0) 
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
        final_score = row_score/(length(gs_row)-length(skip_cols))
        @assert final_score <= 1 "Final score for this row is $final_score"
        return final_score,failed_indices
    else
        return 0, "missing"
    end
end


