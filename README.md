[![Documentation](https://github.com/Australian-Parliamentary-Speech/Scraper/actions/workflows/documentation.yml/badge.svg)](https://australian-parliamentary-speech.github.io/House_Scraper/)

# Parsing

Step one, in your preferred directory, clone this repo with HTTP or SSH:
```
git clone https://github.com/Australian-Parliamentary-Speech/House_Scraper.git
```

Go into the directory:
```
cd House_Scraper
```

You would have to copy all the downloaded XML files into Inputs/hansard/, first make the directory:

```
mkdir Inputs/hansard/<senate or house>\_xmls
```

```
mv -f ../sgml2xml/<senate or house>\_xmls/* Inputs/hansard/<senate or house>\_xmls
```
```
mv -f ../Download/sitemap\_xmls\_<senate or house>/* Inputs/hansard/<senate or house>\_xmls
```

In the directory, run:
```
./run Inputs/hansard/<senate or house>.toml
```
The output file will be in Outputs/<Senate or House>CSV

To run different year ranges or a specific year, hansard.toml file needs to be editted.


