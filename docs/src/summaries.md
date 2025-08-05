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
```


