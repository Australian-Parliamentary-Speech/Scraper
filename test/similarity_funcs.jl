function similarity_csv(gs_csv,sample_csv,test_setup)
    sample_csvfile = CSV.File(sample_csv)
    gs_rows = eachrow(CSV.File(gs_csv))
    headers = copy(propertynames(sample_csvfile)) 
    sample_rows = eachrow(sample_csvfile)
    header_to_num = edit_set_up(headers)
    num = 1
    success = 0
    content_success = 0
    for gs_row in gs_rows
        gs_row = get_row(gs_row)
        equiv, i = compare_row(sample_rows,gs_row,num,header_to_num,test_setup) 
        if equiv == true
            success += 1
        end
        if equiv != "N/A"
            content_success += 1
        end
    end
    return success/length(gs_rows), content_success/length(gs_rows)
end

function compare_row(sample_rows, gs_row, num, header_to_num,test_setup)
   function equiv(row,gs_row,skip_cols)
        skip_nums = [header_to_num[col] for col in skip_cols]
        for i in 1:length(row)
            if !(i in skip_nums)
                if row[i] != gs_row[i]
                    @show row
                    @show gs_row
                    @show i
                    return false
                end
            end
        end
        return true
    end
    skip_cols = test_setup.skip_cols
    content = gs_row[header_to_num[:content]]
    for i in num:length(sample_rows)
        row = get_row(sample_rows[i])
        sample_content = row[header_to_num[:content]]
        if content == sample_content
            return equiv(row,gs_row,skip_cols),i
        end
    end
    @show gs_row[header_to_num[:content]]
    return "N/A", num
end

function compare_csv(csv1,csv2)
    csvfile1 = CSV.File(csv1)
    csvfile2 = CSV.File(csv2)
    rows1 = eachrow(csvfile1)
    rows2 = eachrow(csvfile2)
    if length(rows1) == length(rows2)
        rows_mismatched = ""
        for i in 1:length(rows1)
            crow1 = collect_row(rows1[i])
            crow2 = collect_row(rows2[i])
            if crow1 != crow2
                rows_mismatched = rows_mismatched * "\"$(i+1)\","
            end
        end
    else
        rows_mismatched = "length not equal"
    end
    return rows_mismatched
end


function compare_outputs(gold_standard_csvs,sample_csv_path,testpath)
    fn = joinpath(testpath,"compatibility_test.csv")
    open(fn,"w") do io
        for gs_csv in gold_standard_csvs
            gs_name = basename(gs_csv)
            sample_csv = joinpath(sample_csv_path,gs_name)
            mismatched = compare_csv(gs_csv,sample_csv)
            println(io,"\"$gs_name\","*mismatched)
        end
    end
end

