using CSV,DataFrames

function process_csv(fn)
    # Open the CSV file
    csvfile = CSV.read(fn,DataFrame)
    
#$    # Process each row
#$    for row in csvfile
#$        # Example: print each row
#$        println(row)
#$        
#$        # Here you can perform your row-wise operations
#$        # For instance, you can access values using column names or indices
#$        # For example, row.column_name or row[index]
#$    end
end

function edit_()
    fn = "question_to_answers_1.csv"
    process_csv(fn)
end
