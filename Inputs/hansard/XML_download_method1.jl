using HTTP
using Gumbo
using Cascadia
using Downloads
using CSV
using DataFrames
using EzXML
using Dates
include("utils.jl")

#this is the function you run
#step1: extract all xml links from the first url
#step2: extract all current up-to-date html links from all xml links 
#step3: compare the current html links with the existing html links (if exists) and create a file containing all the missing htmls
#step4: download the missing html files with query as their names
#step5: extract the missing xml links into a new csv
#step6: download those xmls into their respective folders.
#step7: add the xml links into the existing file if exists.
function sitemap_run()
    today_ = today()
    previous_exist = false
    url = "https://parlinfo.aph.gov.au/sitemap/sitemapindex.xml"
    inter_csv_path = "sitemap_inter_csvs"
    create_dir(inter_csv_path)
    dir_step1 = "sitemap_xmls_step1"
    step1(url,dir_step1)

    step2_html_fn = "$(inter_csv_path)/sitemap_html_step2_$(today_).csv"
    step2_exist_fn = filter(x -> occursin("sitemap_html_step2", x), readdir("$inter_csv_path/"))
    n_total = step2(dir_step1,step2_html_fn)
    step2_missing_fn = "$(inter_csv_path)/sitemap_html_step2_missing.csv"
    step2_final_fn = if length(step2_exist_fn) != 0
        step3("$(inter_csv_path)/$(step2_exist_fn[1])",step2_html_fn,step2_missing_fn)
        step2_missing_fn
        previous_exist = true
    else
        step2_html_fn
    end

    step2_final_fn = step2_html_fn
    dir_step4 = "sitemap_htmls_step4"
    create_dir(dir_step4)
    step4(step2_final_fn,dir_step4)

    step5_xml_fn = "$(inter_csv_path)/site_map_xml_step5_$(today_).csv"
    step5(step5_xml_fn,dir_step4)

    dir_step6 = "sitemap_xmls"
    create_dir(dir_step6)
    step6(step5_xml_fn,dir_step6)

    open("n_total.txt","w") do io
        println(io,n_total)
    end
    
    if previous_exist 
        previous_html_fn = step2_exist_fn
        extra_html_fn = step2_missing_fn
        csv_concatenate(step2_exist_fn,step2_missing_fn)
        previous_xml_fn = filter(x -> occursin("sitemap_xml_step5", x), readdir("$inter_csv_path/"))[1]
        extra_xml_fn = step5_xml_fn
        csv_concatenate(previous_xml_fn,extra_xml_fn)
    end

 

end

function step6(step5_xml_fn,dir_step6)
    download_xml_from_file(step5_xml_fn,dir_step6,"-","\t")
end

function step5(step5_xml_fn,dir_step4)
    filelist = readdir("$(dir_step4)/")
    open(step5_xml_fn, "w") do io
        println(io,join(["date","xml_link","pdf_link"],"\t"))
        for file in filelist
            @show file
            text = read("$(dir_step4)/$file", String)
            doc = Gumbo.parsehtml(text)
            soup = doc.root
            date = find_date_subsoup(soup)
            pdf_link, xml_link = try
            xml_soup = eachmatch(sel"div#documentToc",soup)[1]
            pdf,xml = eachmatch(sel"a",xml_soup)[1].attributes["href"],eachmatch(sel"a",xml_soup)[2].attributes["href"]

            pdf_link =  "https://parlinfo.aph.gov.au/$pdf"
            xml_link = "https://parlinfo.aph.gov.au/$xml"
            (pdf_link,xml_link)
            catch
                pdf_link = xml_link = "N/A"
                (pdf_link,xml_link)
            end
            println(io, join([date, xml_link, pdf_link,file], "\t"))
        end 
    end
end




function find_date_subsoup(soup)
    date = try
        subsoup = eachmatch(sel"div.twoBoxForm",soup)[2]
        div = eachmatch(sel"div.metaPadding",subsoup)[1]
        date_soup = eachmatch(sel"p.mdItem",div)[1]
        date = date_soup.children[1].text
    catch
        date = "N/A"
    end
    return date
end


function step4(step2_final_fn,dir_step4)
    function find_query_from_url(url)
        pattern = r"query=([^;]+);"
        m = match(pattern, url)
        return m.captures[1]
    end
    html_missing = readlines(step2_final_fn)
    for html in html_missing
        continue_ = true
        while continue_
            try
                response = get_response(html)
                html_content = String(response.body)
                query = find_query_from_url(html)
                filename = "$(dir_step4)/$(query).html"
                open(filename, "w") do file
                    write(file,html_content)
                end
                continue_ = false
            catch e
                print("Waiting for Internet to respond...") 
                println("An error occurred: $e")
                sleep(50)
                continue_ = true
            end 
        end
    end   
end

function step3(step2_exist_fn,step2_html_fn,step2_missing_fn)
    html_exist = readlines(step2_exist_fn)
    html_new = readlines(step2_html_fn)
    #performance check
    html_missing = html_new[html_new .∉ Ref(html_exist)]
#    html_missing = setdiff(html_new,html_exist)
    open(step2_missing_fn,"w") do io
        for html in html_missing
            println(io,html)
        end
    end
end

function step2(dir_step1,step2_html_fn)
    function if_link_hansard(link)
        return occursin("hansardr80",link) || occursin("hansardr",link)
    end

    function compare_links(url1::String, url2::String)::Bool
        pattern = r"%2F\d+%22"    
        cleaned_url1 = replace(url1, pattern => "")
        cleaned_url2 = replace(url2, pattern => "")
        return cleaned_url1 == cleaned_url2
    end

    filelist = readdir("$dir_step1/")
    n_total = 0
    open(step2_html_fn,"w") do io
        for xml_file in filelist
            xdoc = readxml("$dir_step1/$xml_file")
            soup = root(xdoc)
            eles = elements(soup)
            prev_link = " "
            for ele in eles
                link = elements(ele)[1].content
                if if_link_hansard(link)
                    n_total += 1
                    @show n_total
                    if !(compare_links(link,prev_link))
                        prev_link = link
                        println(io,link)
                    end
                end
            end
        end
    end
    return n_total
end

function step1(url,dir_step1)
    create_dir("$(dir_step1)/")
    download_xml(url,"xml_for_step1.xml")
    xdoc = readxml("xml_for_step1.xml")
    soup = root(xdoc)
    eles = elements(soup)
    first_sets = []
    fn = 1
    for ele in eles
        link = elements(ele)[1].content
        download_xml(link,"$dir_step1/$fn.xml")
        fn+=1
        @show fn
    end
end


