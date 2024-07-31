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

For a single xml file:
```
[ global ]
    output_path = "../../Outputs/hansard"

[[ XML ]]
    filename = "xmls/2008/2008-12-01.xml"

[ general_options ]
    csv_exist = false
    edit = true
    year = [1900,2024]
```
Note that if the date for the single xml is out of range from the year defined, the program might not run.

For a directory of xmls:
```
[ global ]
    output_path = "../../Outputs/hansard"

[[ XML_DIR ]]
    path = "xmls"

[ general_options ]
    csv_exist = false
    edit = true
    year = [1900,2024]
```

## Outputs

Where the output files go can be edited by the user in the toml file shown above. Currently, they are stored in Outputs/hansard.


