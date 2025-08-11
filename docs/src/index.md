# ParlinfoSpeechScraper  

This project is divided into three parts, which correspond to three repos: Download, sgml2xml, and Scraper. The repo Download downloads the XML files directly from the Parlinfo roadmap. The repo sgml2xml downloads the sgml files and convert them into XML files. This is for the years where the XML files are missing. Finally Scraper parses the XML files and produces CSV files that contain all the speech information.  

# Quick start

# Windows users

All commands here work natively for Mac and Linux users.

Since this project uses bash scripts (e.g., ```./run house```), Windows users need a bash environment to run these commands. One option is to install [Git Windows](https://git-scm.com/downloads/win) to create a bash shell environment. Once installed, right click "Git Bash Here" and run bash commands there. 


# Install Julia

To run the package, Julia needs to be installed. For help see https://julialang.org/install/


# Download the XML files

Step one, in your preferred directory, for example HansardScraper/, clone the Download repo with HTTP or SSH:
```
cd HansardScraper
```

```
git clone https://github.com/Australian-Parliamentary-Speech/Download.git
```

Go into the directory:
```
cd Download
```

In the directory (in a bash environment), run:
```
./run house
```
or
```
./run senate
```

The XML files should be in the directory sitemap_xmls_senate or sitemap_xmls_house.


# Download the SGML files and convert them to XML files
Step one, in your preferred directory, for example HansardScraper/, clone the sgml2xml repo with HTTP or SSH:
```
cd HansardScraper
```
```
git clone https://github.com/Australian-Parliamentary-Speech/sgml2xml.git
```

Go into the directory
```
cd sgml2xml
```
 
In the directory (in a bash environment), run:
```
./run house
```

or 
```
./run senate
```

The XML files should be in the directory senate_xmls or house_xmls


# Parsing

Step one, in your preferred directory, for example HansardScraper/, clone this repo with HTTP or SSH:
```
cd HansardScraper
```
```
git clone https://github.com/Australian-Parliamentary-Speech/Scraper.git
```

Go into the directory:
```
cd Scraper
```

You would have to copy all the downloaded XML files into Inputs/hansard/, first make the directory:

For Senate:
```
mkdir -p Inputs/hansard/senate_xmls
```
```
mv -f ../sgml2xml/senate_xmls/* Inputs/hansard/senate_xmls
```
```
mv -f ../Download/sitemap_xmls_senate/* Inputs/hansard/senate_xmls
```

For House:
```
mkdir -p Inputs/hansard/house_xmls
```
```
mv -f ../sgml2xml/house_xmls/* Inputs/hansard/house_xmls
```
```
mv -f ../Download/sitemap_xmls_house/* Inputs/hansard/house_xmls
```

In the directory, run:

For Senate: 
```
./run Inputs/hansard/senate.toml
```

For House:
```
./run Inputs/hansard/house.toml
```


The output file will be in Outputs/SenateCSV or Outputs/HouseCSV

To run different year ranges or a specific year,senate.toml or house.toml file needs to be editted (details see [here](https://australian-parliamentary-speech.github.io/Scraper/)).



For Windows users:

For Senate:

```
mkdir Inputs\hansard\senate_xmls
```

```
move /Y ..\sgml2xml\senate_xmls\* Inputs\hansard\senate_xmls\
```

```
move /Y ..\Download\sitemap_xmls_senate\* Inputs\hansard\senate_xmls\
```

In the directory (in a bash environment), run:
```
./run Inputs/hansard/senate.toml
```

For House:

```
mkdir Inputs\hansard\house_xmls
```

```
move /Y ..\sgml2xml\house_xmls\* Inputs\hansard\house_xmls\
```

```
move /Y ..\Download\sitemap_xmls_house\* Inputs\hansard\house_xmls\
```

In the directory (in a bash environment), run:
```
./run Inputs/hansard/house.toml
```

# To inspect how each node is processed

In the directory src/nodes, all the information regarding how each node is processed is stored in the corresponding file. For example, how nodes with nodename "p" would be stored in PNode.jl. The detailed documentation can be accessed in both docs/build/nodes/index.html or the docstrings in each function.


# Overall structure 

The documentation page is arranged as follows:
Normal usage in terms of inputs and outputs is explained in [Usage](usage.md#section-heading), and more advanced interaction that includes adding a node or phase type is explained in [Advanced usage](advusage.md#section-heading). The current implementation of different nodes in all phases is shown in [Nodes](nodes.md#section-heading). [Function references](functionreference.md#section-heading) shows all the docstrings in the program.

