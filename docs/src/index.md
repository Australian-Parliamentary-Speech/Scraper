# ParlinfoSpeechScraper  

This project is divided into three parts, which correspond to three repos: Download, sgml2xml, and Scraper. The repo Download downloads the XML files directly from the Parlinfo roadmap. The repo sgml2xml downloads the sgml files and convert them into XML files. This is for the years where the XML files are missing. Finally Scraper parses the XML files and produces CSV files that contain all the speech information. The detailed documentation is in the documentation page [here](https://australian-parliamentary-speech.github.io/Scraper/). 

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

If you have created these three directories in HansardScraper/ as the example, you can directory run in the directory:

For Senate: 
```
./run Inputs/hansard/senate.toml
```

For House:
```
./run Inputs/hansard/house.toml
```

If you have created these directories differently, you would have to change the input directory in the house.toml file (details on how to change the file see [here](https://australian-parliamentary-speech.github.io/Scraper/))


The output file will be in Outputs/SenateCSV or Outputs/HouseCSV

To run different year ranges or a specific year,senate.toml or house.toml file needs to be editted (details see [here](https://australian-parliamentary-speech.github.io/Scraper/)).



For Windows users:

For Senate:

In the directory (in a bash environment), run:
```
./run Inputs/hansard/senate.toml
```

For House:

In the directory (in a bash environment), run:
```
./run Inputs/hansard/house.toml
```

If you have created these directories differently, you would have to change the input directory in the house.toml file (details on how to change the file see [here](https://australian-parliamentary-speech.github.io/Scraper/))

#(# Overall structure 
The documentation page is arranged as follows:
Normal usage in terms of inputs and outputs is explained in [Usage](usage.md#section-heading), and more advanced interaction that includes adding a node or phase type is explained in [Advanced usage](advusage.md#section-heading). The current implementation of different nodes in all phases is shown in [Nodes](nodes.md#section-heading). [Function references](functionreference.md#section-heading) shows all the docstrings in the program.)

