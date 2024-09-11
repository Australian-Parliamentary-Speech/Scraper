using PyCall
using CSV
using HTTP
using ProgressMeter
include("download_utils.jl")


function download_(url,outputname)
    response = get_response(url)
    open(outputname, "w") do file
        write(file, String(response.body))
    end
end

function sgml2xml(fn,outputfn)
    py"""
    from bs4 import BeautifulSoup

    def xml_generate(fn,outputfn):
        with open(fn, "r", encoding="utf-8") as file:           sgml_content = file.read()
        soup = BeautifulSoup(sgml_content, "lxml")
        xml_content = soup.prettify()
        xml_content = xml_content.replace('<!DOCTYPE hansard PUBLIC "-//PARLINFO//DTD HANSARD STORAGE//EN">', '<!DOCTYPE hansard PUBLIC "-//PARLINFO//DTD HANSARD STORAGE//EN" "hansard.dtd">')
        with open(outputfn, "w", encoding="utf-8") as file:
            file.write(xml_content)
    """
    py"xml_generate"(fn,outputfn)
end

function sgml2xml_run()
    csv_fn = "HansardSGML.csv"
    rows = CSV.Rows(csv_fn)
    xml_dir = joinpath(pwd(),"xmls")
    failed = []
    row_no = 0
    for row in rows
        row_no += 1
        @show row_no
        date,senate,reps = row
        if !ismissing(senate)
            senate = "https://$senate"
            reps = "https://$reps"
            sgml_fn = joinpath(pwd(),"sgmls","$(replace(date, r"/" => "_")).sgm")
            try
                download_(senate,sgml_fn)
                xml_fn = joinpath(pwd(),"xmls","$(replace(date,r"/" => "_")).xml")
                sgml2xml(sgml_fn,xml_fn)
            catch
                push!(failed,senate)
            end
        end
    end
    open("failed_sgml.csv", "w") do file
    for f in failed
        println(file, f)
    end
end
end
