[![Documentation](https://github.com/Australian-Parliamentary-Speech/Scraper/actions/workflows/documentation.yml/badge.svg)](https://australian-parliamentary-speech.github.io/House_Scraper/)

# Parsing

Step one, in your preferred directory, clone this repo with HTTP or SSH:
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
mkdir Inputs/hansard/senate_xmls
```

```
mv -f ../sgml2xml/senate_xmls/* Inputs/hansard/senate_xmls
```
```
mv -f ../Download/sitemap_xmls_senate/* Inputs/hansard/senate_xmls
```
For House:

```
mkdir Inputs/hansard/house_xmls
```

```
mv -f ../sgml2xml/house_xmls/* Inputs/hansard/house_xmls
```
```
mv -f ../Download/sitemap_xmls_house/* Inputs/hansard/house_xmls
```


In the directory, run:
```
./run Inputs/hansard/<senate or house>.toml
```
The output file will be in Outputs/<Senate or House>CSV

To run different year ranges or a specific year, hansard.toml file needs to be editted.


