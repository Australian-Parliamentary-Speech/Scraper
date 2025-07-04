[![Documentation](https://github.com/Australian-Parliamentary-Speech/Scraper/actions/workflows/documentation.yml/badge.svg)](https://australian-parliamentary-speech.github.io/House_Scraper/)

This project is divided into three parts: download, sgml download, and parsing. The detailed documentation is in the documentation page above. 

# Install Julia

To run the package, Julia needs to be installed. Help see https://julialang.org/install/

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

You would have to copy all the downloaded XML files into Inputs/hansard. The input XML files should be in directories with the corresponding year as the directory name. 

In the directory, run:
```
./run Inputs/hansard/hansard.toml
```
The output file will be in Outputs/hansard/{{year}}/

To run different year ranges or a specific year, hansard.toml file needs to be editted.

# To inspect how each node is processed

In the directory src/nodes, all the information regarding how each node is processed is stored in the corresponding file. For example, how nodes with nodename "p" would be stored in PNode.jl. The detailed documentation can be accessed in both docs/build/nodes/index.html or the docstrings in each function.




