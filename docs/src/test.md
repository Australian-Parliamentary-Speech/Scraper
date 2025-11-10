# Testing

## How to test

Head into Scraper directory after cloning, in terminal type:
`julia`

In Julia REPL, press `]`

Then run test by
`test`

The suite of tests will be run. 

## Gold standard testing

The test system in `test/runtests.jl` implements a comprehensive comparison framework between gold standard CSV files and generated sample CSV files with similarity ratio calculation. The system compares generated CSV outputs against gold standard files stored in `test/gold_standard/` by first copying sample files from the main output directory to `test/sample_csv/`, then calculating two types of similarity ratios using the `similarity_csv` function in `similarity_funcs.jl:1`. The comparison works by matching rows based on content fields, then checking all other columns except those specified in the `skip_cols` parameter. It returns two ratios: `success/length(gs\_rows)` (exact matches) and `content_success/length(gs\_rows)` (content-based matches), allowing users to specify which columns to ignore during comparison via the `test_setup.skip_cols` vector in the `test_struct` defined at `runtests.jl:16-18`. The system can be run by uncommenting lines 150-155 in `runtests.jl` and customizing the `skip_cols` array with column names like `:speaker_no`, `:stage_direction_flag`, or `Symbol("page.no")` to exclude specific columns from the similarity calculation.

