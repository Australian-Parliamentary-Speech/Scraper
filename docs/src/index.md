# ParlinfoSpeechScraper

This project is divided into three parts: download, sgml download, and parsing. The detailed documentation is in the documentation page [here](https://australian-parliamentary-speech.github.io/House_Scraper/). 

# Install Julia

To run the package, Julia needs to be installed. For help see https://julialang.org/install/

# Download the XML files

Step one, in your preferred directory, clone the Download repo with HTTP or SSH:
```
git clone https://github.com/Australian-Parliamentary-Speech/Download.git
```

Go into the directory:
```
cd Download
```

In the directory, run:
```
./run house
```
or
```
./run senate
```

The XML files should be in the directory sitemap\_xmls\_senate or sitemap\_xmls\_house.

# Download the SGML files and convert them to XML files
Step one, in your preferred directory, clone the sgml2xml repo with HTTP or SSH:
```
git clone https://github.com/Australian-Parliamentary-Speech/sgml2xml.git
```

Go into the directory
```
cd sgml2xml
```
 
In the directory, run:
```
./run house
```

or 
```
./run senate
```

The XML files should be in the directory senate\_xmls or house\_xmls

# Parsing

Step one, in your preferred directory, clone this repo with HTTP or SSH:
```
git clone https://github.com/Australian-Parliamentary-Speech/House_Scraper.git
```

Go into the directory:
```
cd House_Scraper
```

You would have to copy all the downloaded XML files into Inputs/hansard/:

```
mv -rf ../sgml2xml/house\_xmls/* Inputs/hansard/
```
```
mv -rf ../Download/sitemap\_xmls\_house/* Inputs/hansard/
```
Or


```
mv -rf ../sgml2xml/senate\_xmls/* Inputs/hansard/
```
```
mv -rf ../Download/sitemap\_xmls\_senate/* Inputs/hansard/
```


In the directory, run:
```
./run Inputs/hansard/hansard.toml
```
The output file will be in Outputs/hansard/{{year}}/

To run different year ranges or a specific year, hansard.toml file needs to be editted.

# To inspect how each node is processed

In the directory src/nodes, all the information regarding how each node is processed is stored in the corresponding file. For example, how nodes with nodename "p" would be stored in PNode.jl. The detailed documentation can be accessed in both docs/build/nodes/index.html or the docstrings in each function.


# Overall structure 

The documentation page is arranged as follows:
Normal usage in terms of inputs and outputs is explained in [Usage](usage.md#section-heading), and more advanced interaction that includes adding a node or phase type is explained in [Advanced usage](advusage.md#section-heading). The current implementation of different nodes in all phases is shown in [Nodes](nodes.md#section-heading). [Function references](functionreference.md#section-heading) shows all the docstrings in the program.

