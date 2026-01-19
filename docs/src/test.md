# Testing

## How to test

Head into Scraper directory after cloning, in terminal type:
`julia`

In Julia REPL, press `]`

Then run test by
`test`

The suite of tests will be run. 

## Gold standard testing

To ensure the quality of our data extraction process—from XML files to CSV files before database upload—we use a **gold-standard testing approach**. This helps us measure how accurately our scraper reproduces the information contained in Hansard documents.

**Gold-standard CSV files** refer to manually corrected CSV files. These files are produced by research assistants who compare:

- the scraped CSV output  
- the original XML  
- and the corresponding PDF version of Hansard

The gold-standard files correct only **computationally feasible errors**, such as mis-split speeches or missing flags, but they do **not** fix issues that are impossible to correct automatically (e.g., typos in the original XML).

Each pair of files—**gold standard vs scraped output**—is evaluated using a **similarity score**, which measures how closely our output matches the gold standard.


### How the Similarity Score Works

There are two key challenges when comparing two CSV files:

1. **Row counts may differ**, because speeches may be merged or split.
2. **The same row may not appear in the same position**, so we need a reliable way to match rows.

To address this, we use the **speech content as the row identifier**, since it is typically the most unique attribute.


#### Two Matching Modes

We support two matching modes:

##### 1. Exact Mode

In **exact mode**, the full speech text from the gold standard is used to find an identical match in the scraped output.
 
Limitation: even a tiny difference—like a missing space or a changed quotation mark—can prevent a match.This can cause the score to appear lower than it should be.


##### 2. Fuzzy Mode

To reduce false mismatches, **fuzzy mode** uses **partial text sampling** instead of the full speech.

**How it works:**

- Extract short samples from the gold standard speech.
- Each sample is a set of consecutive words.
- Search for these samples in the scraped output.
- If multiple candidate rows match the samples, select the one that is overall most similar to the gold standard speech.

This allows us to match rows even when minor differences exist.


#### Scoring

The test system implemented in `test/runtests.jl` provides a comprehensive framework for comparing generated CSV outputs against gold-standard CSV files and computing similarity ratios.

The system compares generated CSV files with gold-standard files stored in `test/gold_standard/`. For each test run, sample CSV files are first copied from the main output directory into `test/sample_csv/`. The similarity between each pair of files is then computed using the `similarity_csv` function defined in `similarity_funcs.jl`.

The comparison process works by first matching rows between the gold-standard file and the sample file based on speech content. Once a row is matched, the similarity score for that row is calculated as:

Row similarity = (number of matching cells) / (total number of cells)

where all remaining columns are compared, except for those explicitly excluded via the `skip_cols` parameter. This allows users to ignore metadata fields that are not relevant for assessing scrape quality.

The system returns **two similarity ratios**:

- **Similarity ratio**  
  The similarity ratio between the generated sample CSV file and the corresponding gold-standard CSV file.

- **Maximum similarity ratio**  
  The similarity ratio obtained by comparing the gold-standard CSV file with itself.

The maximum similarity ratio is generally **less than 1**, even though the files being compared are identical. This is expected behaviour and reflects inherent limitations of content-based row matching. In particular, some speeches consist of very short or highly repetitive phrases (such as *“hear, hear”*), which are not unique identifiers. In such cases, the matching algorithm cannot always determine unambiguously which row corresponds to which, leading to a non-perfect similarity score even for identical files.

## Input test toml file
This testing requires two toml files, one is the same input file for the Scraper program (with slight modification of the output\_path), and the other one specifically designed for this testing suite. 

### Test Parameters

- **`skip_cols`**  
  A list of column names to exclude from the similarity comparison.  

- **`which_test`**  
  Specifies the matching strategy used to align rows between the gold-standard CSV and the scraped output.  
  - `"exact"`: Rows are matched only if the full speech text matches exactly.  
  - `"fuzzy"`: Rows are matched using sampled word sequences from the speech text, allowing for minor textual differences.

- **`fuzzy_search`**  
  Controls how speech text is sampled in fuzzy matching mode.  
  This option is only used when `which_test = "fuzzy"`.  
  The value is a two-element array:
  - The first element specifies the number of consecutive words in each sample.
  - The second element specifies the step size (interval) between successive samples.  
  For example, `[5, 2]` means that samples of 5 consecutive words are taken, starting every 2 words along the speech.

- **`which_house`**  
  Indicates which parliamentary house the data belongs to and should be tested against.  
  This is used to select the appropriate gold-standard reference files and parsing rules.  
  Common values include:
  - `"house"`: House of Representatives  
  - `"senate"`: Senate

### Sample input file

```
[ test_params ]
    skip_cols = ["speaker_no","non_speech_flag","page.no","name","electorate","party","role","path","Speaker","Time","Other"]
    #or exact
    which_test = "fuzzy"
    fuzzy_search = [5,2]
    which_house = "house"
```


