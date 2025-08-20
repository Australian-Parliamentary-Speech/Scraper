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

In this section, we give an example of house.toml that has comprehensive explanation, and provides some quick starts that you can use for senate or house.

The comprehensive toml file with all options present:
```
# Parliamentary Speech Scraper Configuration
# This file tells the program what files to process and how to process them
# Lines starting with # are comments and are ignored by the program

[ global ]
    # Where to save the final CSV files after processing
    # Example: if set to "../../Outputs/HouseCSV/hansard", files will be saved there
    output_path = "../../Outputs/HouseCSV/hansard"

# Input Source: Choose ONE of these two options below
# Either process a single XML file OR process all files in a directory

### Option 1: Process a single specific XML file
### Remove the # symbols below to activate this option (and add # to the XML_DIR section)
#[[ XML ]]
#    # Path to a specific XML file to process
#    # Example: "house_xmls/1983/1983_11_09.xml" processes just that one file
#    filename = "house_xmls/1983/1983_11_09.xml"

### Option 2: Process all XML files in a directory (currently active)
[[ XML_DIR ]]
    # Folder containing XML files to process
    # Example: "house_xmls" will process all XML files in that folder
    path = "house_xmls"

[ general_options ]
    # Which parliamentary house to scrape
    # Options: "house" for House of Representatives, "senate" for Senate
    which_house = "house"
    
    # Which years to process
    # Examples: [1996,1997] processes years 1996 and 1997
    #          [2000,2000] processes only year 2000
    #          [1990,2000] processes years 1990 through 2000
    year = [1996,1997]
    
    # Whether to extract data from XML files
    # true = extract data from XML files
    # false = skip scraping, but editing steps will still run on existing data
    xml_parsing = true
    
    # Processing steps to clean and format the data
    # These run in the order listed - each step processes the output of the previous step
    # Common steps: "speaker_time", "re", "free_node", "flatten", "column_decorate"
    edit = ["speaker_time","re","free_node","flatten","flatten","column_decorate","re"]
    
    # Whether to apply editing operations to CSV files
    # true = apply edits to make data cleaner and more usable
    # false = skip edits, keep raw extracted data
    csv_edit = true
    
    # Master switch for all XML processing functions
    # true = run all XML processing steps normally
    # false = skip all XML functions, only write samples or remove processing steps
    run_xml_toggle = true
    
    # Whether to create sample output files for testing
    # true = create smaller sample files to check if processing works correctly
    # false = process all data without creating samples
    sample = true
    
    # Which intermediate CSV files to delete after processing (to save disk space)
    # The program creates files named like "data_step_0.csv", "data_step_1.csv", etc.
    # This setting deletes those intermediate files, keeping only the final result
    # Example: [0,1,2,3,4,5,6] deletes steps 0 through 6 (keeps only the final step)
    #         [0,1,2] deletes only the first 3 intermediate files
    #         [] keeps all intermediate files (uses more disk space)
    remove_nums = [0,1,2,3,4,5,6]
    
    # Whether to clean up XML filenames
    # true = rename files to standard format
    # false = keep original filenames
    xml_name_clean = false
```
Here are some quick starts:

For a single xml file (for senate):
```
# Where the output would go
[ global ]
    output_path = "../../Outputs/SenateCSV/hansard"

# The XML file you run
[[ XML ]]
    filename = "senate_xmls/1999/1999_06_25.xml"

[ general_options ]
    # senate or house
    which_house = "senate"
    # year range
    year = [1901,2025]
    # false to skip scraping, edit still remains
    xml_parsing = true
    # steps for editting
    edit = ["speaker_time","re","free_node","flatten","flatten","column_decorate","re"]
    #false to skip edits
    csv_edit = true
    #false to skip all run xml functions and only to write samples or remove steps
    run_xml_toggle = true
    sample = false
    # whether to remove some steps once program finishes
    remove_nums = [0,1,2,3,4,5,6]
    # does it require xml name cleaning to ensure dates are in the right format
    xml_name_clean = false
```
Note that if the date for the single xml is out of range from the year defined, the program might not run.

For a directory of xmls (for Senate):

```
# Where the output would go
[ global ]
    output_path = "../../Outputs/SenateCSV/hansard"

# Where the input xmls are stored
[[ XML_DIR ]]
    path = "senate_xmls"

[ general_options ]
    # senate or house
    which_house = "senate"
    # year range
    year = [1901,2025]
    # false to skip scraping, edit still remains
    xml_parsing = true
    # steps for editting
    edit = ["speaker_time","re","free_node","flatten","flatten","column_decorate","re"]
    #false to skip edits
    csv_edit = true
    #false to skip all run xml functions and only to write samples or remove steps
    run_xml_toggle = true
    sample = false
    # whether to remove some steps once program finishes
    remove_nums = [0,1,2,3,4,5,6]
    # does it require xml name cleaning to ensure dates are in the right format
    xml_name_clean = false
```
For a single xml file (for House):
```
# Where the output would go
[ global ]
    output_path = "../../Outputs/HouseCSV/hansard"

# The XML file you run
[[ XML ]]
    filename = "house_xmls/1999/1999_06_25.xml"

[ general_options ]
    # senate or house
    which_house = "house"
    # year range
    year = [1901,2025]
    # false to skip scraping, edit still remains
    xml_parsing = true
    # steps for editting
    edit = ["speaker_time","re","free_node","flatten","flatten","column_decorate","re"]
    #false to skip edits
    csv_edit = true
    #false to skip all run xml functions and only to write samples or remove steps
    run_xml_toggle = true
    sample = false
    # whether to remove some steps once program finishes
    remove_nums = [0,1,2,3,4,5,6]
    # does it require xml name cleaning to ensure dates are in the right format
    xml_name_clean = false
```
Note that if the date for the single xml is out of range from the year defined, the program might not run.

For a directory of xmls (for House):

```
# Where the output would go
[ global ]
    output_path = "../../Outputs/HouseCSV/hansard"

# Where the input xmls are stored
[[ XML_DIR ]]
    path = "house_xmls"

[ general_options ]
    # senate or house
    which_house = "house"
    # year range
    year = [1901,2025]
    # false to skip scraping, edit still remains
    xml_parsing = true
    # steps for editting
    edit = ["speaker_time","re","free_node","flatten","flatten","column_decorate","re"]
    #false to skip edits
    csv_edit = true
    #false to skip all run xml functions and only to write samples or remove steps
    run_xml_toggle = true
    sample = false
    # whether to remove some steps once program finishes
    remove_nums = [0,1,2,3,4,5,6]
    # does it require xml name cleaning to ensure dates are in the right format
    xml_name_clean = false
```


## Outputs

Where the output files go can be edited by the user in the toml file shown above. Currently, they are stored in Outputs/hansard.


