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


### required file:
hansard.dtd (converts sgml to xml)
HansardSGML.csv (all the links required)
sgml2xml.jl
download\_utils.jl (hidden file)
run (bash script)


