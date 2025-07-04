# Downloading the XML files

We use the sitemap provided by <https://parlinfo.aph.gov.au/sitemap/sitemapindex.xml> to download the XML files. The sitemap contains a list of XML links which then provide with the html pages where the links for the debate XML pages were provided. Here we give a brief overlook on the steps the program takes to download the XMLs and the information in the logfile if anything goes wrong. All csv files will be stored in **sitemap\_inter\_csvs/**. 

To update or run for the first time, git clone this repo and run:

```console
./run <senate or house>
```

## required file
XML\_download\_method1.jl
utils.jl
download\_utils.jl (hidden file)
run (bash file)

## logfile
The logfiles are in sitemap\_logfiles/. It contains information on how many links in total were detected (to compare with the parlinfo website) and how many missing were updated from this run.


## Step 1: download the first layer XML pages 

The first step downloads each XML page provided by the first sitemap. Each of these pages would contain a list of HTML links. This step will run every time regardless if previous runs were conducted. The reason for that is this first link gets updated with overwritten names everytime. 

## Step 2: extract all the html links

The second step extracts all the HTML links from the XML files downloaded in step 1 into a csv file **sitemap\_html\_step2_<dateofcreation>.csv**.

## Step 3: compare the current csv with any existing file

This step is run if any other csv from the previous run is detected. It compares the csv generated in step 2 and the previous csv and generate a csv file containing the HTML links in current run and not in the previous run. The resulting file would be named **sitemap\_html\_step2\_missing.csv**.

If no existing previous run is detected, this step will not run.

## Step 4: download the html files

This step downloads all the HTML files either from the missing ones or the entire csv from step 2, depending on if previous run was detected. The html files will be downloaded to directory **sitemap\_htmls\_step4\_<dateofcreation>**. If any file has failed t download, the links would appear in the log file in directory **sitemap\_logfiles/**.

## Step 5: extract the xml links 

This step extracts all the missing xml links (or the complete set) into a csv called **site\_map\_xml\_step5\_<dateofcreation>.csv**

## Step 6: download the xml files

This step downloads the xml files from the links provided in step 5 into **sitemap\_xmls/**.

## Step 7: add the new xml links into the existing file and remove the old run.

This step just cleans up the old files and gets ready for the next run. The total number of links detected will also show up in the logfile to compare with the result from <https://parlinfo.aph.gov.au/parlInfo/search/summary/summary.w3p;adv%3Dyes;orderBy%3D_fragment_number,doc_date-rev;query%3DDataset%3Ahansardr,hansardr80;resCount%3DDefault>. It is recommened to delete some of the **sitemap\_htmls\_step4\_<dateofcreation>** so they don't stack up too much. But it is not necessary. 







