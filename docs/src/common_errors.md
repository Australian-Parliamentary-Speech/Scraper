# Common Errors

The codebase includes several error messages for debugging and validation purposes:

* **Utils.jl**: `Assert Error length(collect(skipmissing(row))) == length(row)`
    - The row contains missing

* **NodeModule.jl**: `@error "which_house is not correctly given"`
    - if which\_house is not senate or house

* **NodeModule.jl**: `Assert orig_doc == curr_doc`
    - something is wrong with the process of writing toy xmls

* **QuestionNode**: `@error "No phase was produced in questionnode"` 
    - indicates missing phase data in question processing

* **SpeechNode.**: `@error "No phase was produced in speechnode"`
    - indicates missing phase data in speech processing

# Information
Things that are recorded in the log.txt in the output directory:

* **RunModule.jl**: `@info "XML and Filename do not agree on dates: year$fn_year,month$fn_month,day$fn_day"`
- This records all instances where the dates differ from the XML content and the name of the XML file.

* **RunModule.jl**: `@info "Failure retrieving date from XML: year$year,month$month,day$day"`
- This records all instances where dates were not extracted successfully from the XML. 

* **RunModule.jl**: `@info "$year is not a valid input directory"`
- The requested year does not exist in the input.

* **RunModule.jl**: `@info "$fn did not pass opening the xml..."`
- The XML file is corrupted.

* **RunModule.jl**: `@info "$path is not there to remove"`
- The intermediate files are not there to remove.

* **RunModule.jl**: `"Sampling $(fn) failed: file not found"`
- The files are not in the output path to be sampled. 

* **NodeModule.jl**`:@error "which_house is not correctly given"`
 - Check your input\_file, which\_house is not given in the correct format.


