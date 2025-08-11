# Usage

Here we start with the description of the user interface regarding inputs and outputs. Details about some structurally important functions are listed after.

## Inputs
The input xml files live in the directory src/Inputs/, and specifically where they live is specified in the toml file. For example, as currently stated in Inputs/hansard/hansard.toml, the xmls live in src/Inputs/hansard/xmls. You can define your own toml and your own directory of where the xmls live. To run the program, head to the src/ directory and run:

```console 
./run Inputs/hansard/hansard.toml
```
or 

```console
./run <insert your toml file>
```

### Input toml file

The input toml file allows the user to select options for the run. The output directory, the year range, whether the first step of the process is done and whether edit is preferred are the options that the user can edit. In terms of what files the program runs, we have two modes available when running the program. It can run one xml file or a directory of xml files. 

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


