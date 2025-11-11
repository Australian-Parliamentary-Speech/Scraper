[![Documentation](https://github.com/Australian-Parliamentary-Speech/Scraper/actions/workflows/documentation.yml/badge.svg)](https://australian-parliamentary-speech.github.io/Scraper/)

# Parsing

## Step one, in your preferred directory, clone this repo with HTTP or SSH:
```
git clone https://github.com/Australian-Parliamentary-Speech/Scraper.git
```


## Step two, edit the toml file located in ~/Inputs/house.toml [or senate.toml]

Ensure that your global path is where you want to save your outputs (for example):
[ global ]
    output_path = "../Outputs/HouseCSV/hansard"

ensure that: 

The outputs of the download repo are located in the first XML_DIR (for example): 
[[ XML_DIR ]]
    path = "../../Download/house_xmls"

The outputs of the sgml2xml repo are located in the first XML_DIR (for example): 
[[ XML_DIR ]]
    path = "../../sgml2xml/house_xmls"

That any reserved xmls are correctly pointed:
[[ XML_DIR ]]
    path = "../../sgml2xml/house_reserve_xmls"


Ensure that general options are correctly specified. This will usually mean matching the correct chamber in which_house, and making sure that the desired years for analysis are specified:

[ general_options ]
    which_house = "house"
    year = [1981, 1998]
    xml_parsing = true
    edit = ["speaker_time","re","stage_direction","free_node","flatten","flatten","column_decorate","final_re"]
    csv_edit = true
    run_xml_toggle = true
    sample = true
    remove_nums = [0,1,2,3,4,5,6,7]
    xml_name_clean = false

## Step three, run 

With the terminal directory set to ~/Scraper: 

```
./run Inputs/house.toml`
```

