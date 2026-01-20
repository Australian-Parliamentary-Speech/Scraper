# Usage

Here we start with the description of the user interface regarding inputs and outputs. Details about some structurally important functions are listed after.

## Inputs
The input xml files live in the directory src/Inputs/, and specifically where they live is specified in the toml file. For example, as currently stated in Inputs/hansard/hansard.toml, the xmls live in src/Inputs/hansard/xmls. You can define your own toml and your own directory of where the xmls live. To run the program, head to the src/ directory and run:

```console 
./run Inputs/hansard/house.toml
```
or 

```console
./run <insert your toml file>
```

### Input toml file

The input toml file allows the user to select options for the run. The output directory, the year range, whether the first step of the process is done and whether edit is preferred are the options that the user can edit. In terms of what files the program runs, we have two modes available when running the program. It can run one xml file or a directory of xml files.

In this section, we give a comprehensive explanation of all the toml options, and provides some quick starts that you can use for senate or house.

* output\_path (under [ global ]): 
    - where to save the final CSV files after processing
    Example: if set to "../../Outputs/HouseCSV/hansard", files will be saved there 

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
    - false = skip scraping, assuming there exists outputs 

* edit (under [general\_options])
    - Processing steps to clean and format the data
    - These run in the order listed - each step processes the output of the previous step
    - Common steps: "speaker\_time", "re", "free\_node", "flatten", "column\_decorate" (more explanation see below)
    - The order matters. It is strongly recommended to use the list provided in the sample file for the best outcome 

* csv\_edit 
    - Whether to apply editing operations to CSV files
    - true = apply edits 
    - false = skip edits, keep raw extracted data

* run\_xml\_toggle
    - Master switch for all XML processing functions
    - true = run all XML processing steps normally
    - false = skip all XML functions, only write samples or remove processing steps. 

* sample
    - Whether to create sample output files for testing
    - true = create smaller sample files to check if processing works correctly
    - false = process all data without creating samples

* remove\_nums 
    - Which intermediate CSV files to delete after processing (to save disk space)
    - The program creates files named like "data\_step\_0.csv", "data\_step\_1.csv", etc.
    - This setting deletes those intermediate files, keeping only the final result
    - Example: [0,1,2,3,4,5,6] deletes steps 0 through 6 (keeps only the final step)
    - Example: [0,1,2] deletes only the first 3 intermediate files
    - Example: [] keeps all intermediate files (uses more disk space)

* xml\_name\_clean
    - Whether to clean up XML filenames for inconsistent date formats
    - true = rename files to standard format
    - false = keep original filenames


### Quick start input files

For a single xml file (for senate):
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
Note that if the date for the single xml is out of range from the year defined, the program might not run.

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
For a single xml file (for House):
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

Note that if the date for the single xml is out of range from the year defined, the program might not run.

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

Identifies and standardises procedural (non-speech) rows.

- Detects parliamentary stage directions using known procedural phrases
- Clears speaker attribution for procedural rows


### speaker\_time (often not used)
Extracts timing and auxiliary information from speech rows.

- Separates embedded time markers from speech content into a dedicated time column
- Adds new columns for speaker label, time, and other extracted metadata
- Moves non-speaker or descriptive labels into an auxiliary “Other” field

### re

Extracts speaker information and cleans speech text.

- Identifies speaker names embedded in speech content and moves them to the speaker column
- Detects and labels interjections
- Makes an attempt to infer missing speaker names from structured text
- Removes speaker labels, punctuation artefacts, and formatting noise from speech content
- Drops rows with empty speech content

### free\_node

Resolves unattributed (“free-flowing”) rows within a debate.

- Assigns free or missing speaker names to the most recent valid speaker in the same debate
- Attributes quoted or continued speech to the correct speaker where possible
- Does not cross debate or sub-debate boundaries
- Removes placeholder speaker labels from the output

### flatten

Flattens multi-row speeches into single rows.

- Merges consecutive speech rows from the same speaker into one row
- Appends child speech content to the parent speech
- Stops merging when a new speaker, debate context, or stage direction is encountered
- Ensures each speech appears only once in the output

### final\_re

Applies final cleaning and standardisation to the CSV output.

- Fills missing speaker names from available speaker metadata
- Reclassifies rows with speaker information as speech
- Cleans speech text by removing leading punctuation and excess whitespace
- Drops rows with empty speech content
 


