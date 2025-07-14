# Summaries

This page contains some summary statistics we have calculated for our scraping result.



## Number of sitting days detected for each year
```@eval
   using CSV, DataFrames
   using Latexify
   using Dates
   using ParlinfoSpeechScraper

   current_year = year(today())

   parent_dir = pathof(ParlinfoSpeechScraper)
   dir_ = joinpath(dirname(dirname(parent_dir)),"test")
   df = CSV.read(joinpath(dir_,"all_csv_dates.csv"),DataFrame;header=false)
    
   years = collect(1901:current_year)
   counts = [0 for i in 1:length(years)]
   n = 1900
   for row in eachrow(df)
        year = row[1]
        count_ = 0
        for ele in row
            if ismissing(ele)
                count_ += 1
            end
        end
        counts[year-n] = count_
   end
   M = vcat(years',counts')
   sides = ["Year","Number of sitting days detected"]
   mdtable(M,latex=false,side=sides)
```


