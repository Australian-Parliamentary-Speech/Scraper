# Usage

Here we desribe the user interface regarding inputs and outputs. 

## Input XML files
The location of the input XML files is configured via a TOML file in src/Inputs/. The default configuration at Inputs/hansard/<house|senate>.toml specifies three directories under XML\_DIR. To use custom input paths, provide your own TOML file and set XML_DIR accordingly.

To run the program, navigate to the src/ directory and run:

```console 
./run Inputs/hansard/house.toml
```
or 

```console
./run <insert your TOML file>
```

### Input TOML file
The input TOML file defines all configuration for the program. This section documents every available option, and provides ready-to-use starter TOML files for both the Senate and the House.

* output\_path (under [ global ]): 
    - where to save the final CSV files after processing
    Example: if set to "../../Outputs/HouseCSV/hansard", the output files will be saved there 

* path (under [[ XML\_DIR ]]):
    - You can either run one single file or one entire directory. 
    - Example for an entire directory: "house\_xmls" will process all XML files in that folder
    - Example for a single file: "house\_xmls/1983/1983\_11\_09.xml" processes just that one file


* which\_house (under [general\_options] )
    - Options: "house" for House of Representatives, "senate" for Senate
 
* year (under [general\_options])
    - Which years to process
    - Example: [1996,1997] processes years 1996 and 1997
    - Example: [2000,2000] processes only year 2000

* xml\_parsing (under [general\_options])
    - Whether to skip scraping 
    - true = extract data from XML files
    - false = skip scraping, assuming there exists outputs. This is for runs that require editting only. 

* edit (under [general\_options])
    - Processing steps to clean and format the CSV files after parsing
    - These run in the order listed - each step processes the output of the previous step
    - Common steps: "speaker\_time", "re", "free\_node", "flatten", "column\_decorate" (more explanation see below)
    - The order matters. It is strongly recommended to use the list provided in the sample file for the best outcome 

* csv\_edit 
    - Whether to apply editing operations to CSV files
    - true = apply edits 
    - false = skip edits, keep raw extracted data

* run\_xml\_toggle
    - Master switch for all XML processing functions
    - true = run all XML processing steps normally. This is the recommended option.
    - false = skip all XML functions, only write samples or remove processing steps. 

* sample
    - Whether to create sample output files for testing
    - true = create smaller sample files to check if processing works correctly
    - false = process all data without creating samples

* remove\_nums 
    - Which intermediate CSV files to delete after processing (to save disk space)
    - The program creates files named like "data\_step\_0.csv", "data\_step\_1.csv", etc. This setting deletes those intermediate files, keeping only the final result
    - Default: [0,1,2,3,4,5,6,7] deletes everything except the final step.
    - Example: [0,1,2,3,4,5,6] deletes steps 0 through 6 (keeps only the final step)
    - Example: [0,1,2] deletes only the first 3 intermediate files
    - Example: [] keeps all intermediate files (uses more disk space)

* xml\_name\_clean
    - Whether to clean up XML filenames for inconsistent date formats
    - true = rename files to standard format. This is the recommended option.
    - false = keep original filenames


### Quick start input files

For a single XML file (for senate):
```
[ global ]
    output_path = "../../Outputs/SenateCSV/hansard"

[[ XML ]]
    filename = "hansard/senate_reserve_xmls/1999/1999_06_25.xml"

[ general_options ]
    which_house = "senate"
    year = [1901,2025]
    xml_parsing = true
    edit = ["speaker_time","re","stage_direction","free_node","flatten","flatten","column_decorate","final_re"]
    csv_edit = true
    run_xml_toggle = true
    sample = true
    remove_nums = [0,1,2,3,4,5,6,7]
    xml_name_clean = false
```
Note that if the date for the single XML is out of range from the year defined, the program might not run.

For a directory of xmls (for Senate):

```
[ global ]
    output_path = "../../Outputs/SenateCSV/hansard"

[[ XML_DIR ]]
    path = "hansard/senate_reserve_xmls"

[ general_options ]
    which_house = "senate"
    year = [1901,2025]
    xml_parsing = true
    edit = ["speaker_time","re","free_node","flatten","flatten","column_decorate","re"]
    csv_edit = true
    run_xml_toggle = true
    sample = false
    remove_nums = [0,1,2,3,4,5,6]
    xml_name_clean = false
```
For a single XML file (for House):
```
[ global ]
    output_path = "../Outputs/HouseCSV/hansard"

[[ XML ]]
    filename = "hansard/house_reserve_xmls/2010/2010_02_10.xml"

[ general_options ]
    which_house = "house"
    year = [1901,2025]
    xml_parsing = true
    edit = ["speaker_time","re","stage_direction","free_node","flatten","flatten","column_decorate","final_re"]
    csv_edit = true
    run_xml_toggle = true
    sample = true
    remove_nums = [0,1,2,3,4,5,6,7]
    xml_name_clean = false
```

Note that if the date for the single XML is out of range from the year defined, the program might not run.

For a directory of xmls (for House), this is also anexample where you can run multiple directories:

```
[ global ]
    output_path = "../Outputs/HouseCSV/hansard"

###choose one: XML or XML_DIR
#[[ XML ]]
#    filename = "hansard/house_reserve_xmls/2010/2010_02_10.xml"

[[ XML_DIR ]]
    path = "../../Download/house_xmls"

[[ XML_DIR ]]
    path = "../../sgml2xml/house_reserve_xmls"

[[ XML_DIR ]]
    path = "../../sgml2xml/house_xmls"


[ general_options ]
    which_house = "house"
    year = [1901,2025]
    xml_parsing = true
    edit = ["speaker_time","re","stage_direction","free_node","flatten","flatten","column_decorate","final_re"]
    csv_edit = true
    run_xml_toggle = true
    sample = true
    remove_nums = [0,1,2,3,4,5,6,7]
    xml_name_clean = false
```

## Edit steps

### stage\_direction

Identifies the parliamentary stage directions.

- Detects parliamentary stage directions using known procedural phrases
- Set speaker to "N/A". 


### speaker\_time
Extracts timing and auxiliary information from speech rows. This is an early feature that was later deemed not very useful.

- Separates embedded time markers from speech content into a dedicated time column
- Adds new columns for speaker label, time, and other extracted metadata

### re

Extracts speaker information and cleans speech text.

- Identifies speaker names embedded in speech content and moves them to the speaker column
- Detects and labels interjections
- Makes an attempt to infer missing speaker names from structured text
- Removes speaker prefixes and formatting noise from speech content
- Drops rows with empty speech content

### free\_node

There are many unauthored speeches from the raw processing of XML. This step resolves unattributed (“free-flowing”) rows within a debate.

- Assigns free or missing speaker names to the most recent valid speaker in the same debate
- Attributes quoted or continued speech to the correct speaker where possible
- Does not cross debate or sub-debate boundaries
- Removes placeholder speaker labels from the output

### flatten

Flattens multi-row speeches into single rows.

- Merges consecutive speech rows from the same speaker into one row
- Stops merging when a new speaker, debate context, or stage direction is encountered

### final\_re

Applies final cleaning and standardisation to the CSV output.

- Reclassifies rows with speaker information as speech
- Cleans speech text by removing leading punctuation and excess whitespace
- Drops rows with empty speech content
 


