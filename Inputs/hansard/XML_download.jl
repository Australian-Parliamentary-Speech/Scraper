using HTTP
using Gumbo
using Cascadia
using Downloads
using CSV
using DataFrames
using EzXML
include("download_utils.jl")

function create_dir(directory::AbstractString)
    if !isdir(directory)
        mkdir(directory)
        println("Directory created: $directory")
    end
end

function download_xml(url,fname)
    response = get_response(url)
    open("$fname", "w") do file
        write(file, String(response.body))
    end
end

function read_csv(file_path::AbstractString,delim_=" ")
    data = CSV.File(file_path, delim=delim_) |> DataFrame
    file_names = data[!,1]
    urls = data[!, 2]    
    return file_names,urls[1:end]
end

function find_xml_link_from_page(href)
    page_soup = get_soup(href)
    xml_img = eachmatch(sel"img[title~=XML]",page_soup)
    if !isnothing(xml_img)&& length(xml_img)>0 
        xml_link = xml_img[1].parent.attributes["href"]
        return "https://parlinfo.aph.gov.au/$xml_link"
    else
        return "N/A"
    end
end

function get_soup(link)
    response = get_response(link)
    doc = Gumbo.parsehtml(String(response))
    soup = doc.root
    return soup
end

function get_page_number(soup)
    box = eachmatch(sel"div.numbers",soup)[1]
    number = eachmatch(sel"b",box)[1]
    return number.children[1].text
end

function write_xml_one_page(link,io)
    dates = []
    xml_links = []
    soup = get_soup(link)
    result_soup = eachmatch(sel"ul#results",soup)[1]
    for one_result in eachmatch(sel"div.resultContent",result_soup)
        link_soup = eachmatch(sel"div.sumLink",one_result)[1]
        href = eachmatch(sel"a",link_soup)[1].attributes["href"]
        xml_link = find_xml_link_from_page(href)

        date_soup = eachmatch(sel"div.sumMeta",one_result)[1]
        date_text,collection,ID_text,source = split(date_soup.children[1].text,"-")
        date = match(r"\d{2}/\d{2}/\d{4}", date_text).match

        push!(xml_links,xml_link)
        if isnothing(date)
            date = "N/A"
        end
        @show date
        push!(dates,date)
    end

    for i in 1:length(dates)
        println(io, join([dates[i], xml_links[i], link], " "))
    end
    return soup
end

function next_page_link(soup)
    next_image = eachmatch(sel"img[title~=Next]",soup)[1]
    next_link = next_image.parent.attributes["href"]
    return next_link
end

#this is the function you run
function write_xml_links()
    link = "https://parlinfo.aph.gov.au/parlInfo/search/summary/summary.w3p;adv%3Dyes;orderBy%3D_fragment_number,doc_date-rev;query%3DDataset%3Ahansardr,hansardr80;resCount%3D200"
    maxnumber = 4800
    number = 1
    open("xml_urls_final_.csv", "w") do io
        while number < maxnumber
            soup = write_xml_one_page(link,io)
            link = next_page_link(soup)
            @show link
            number += 1
            @show number
            sleep(50)
        end
    end
end

function download_xml_from_file(fn="xml_urls_final.csv",sept="/",delim_=" ")
    date_cells,urls = read_csv(fn,delim_)
    function cell_to_date(cell)
        day,month,year = split(cell,sept)
        return day,month,year
    end
    open("download_debug.csv", "w") do io
        for n in 1:length(urls)
            url = urls[n]
            if date_cells[n] != "N/A"
                day,month,year = cell_to_date(date_cells[n])
                fname = "xmls_roadmap/$year/$(year)_$(month)_$(day).xml"
                create_dir("xmls_roadmap/$year/")
                @show year
            end
            try
                download_xml(url,fname)
            catch
                println(io,[url])
            end
        end
    end
end


#############################################
function sitemap_run()
    #set up
    year_to_start = 1901
    dir_step1 = "sitemap_xmls_step1"
    dir_step2 = "sitemap_htmls_step2"
    create_dir("$(dir_step1)/")
    create_dir("$(dir_step2)/")
    #what is the path of the csv file containing all xml links?
    fn = "xml_urls_sitemap.csv" 
 

    #first step
    print("Starting the first step to get the xml files...")
#    get_xml_files_sitemap_step1(dir_step1)
    #second step
    print("Starting the second step to download all html files ...")
    step2_run(year_to_start,dir_step1,dir_step2)
    #third step
    print("Starting the third step to write xml links into a csv...")
    sitemap_get_xml_links_step3(fn)
    #fourth step
    print("Starting the fourth step to download all xml files...")
    download_xml_from_file(fn="xml_urls_final.csv","-","\t")
end

function get_xml_files_sitemap_step1(dir)
    url = "https://parlinfo.aph.gov.au/sitemap/sitemapindex.xml"
    download_xml(url,"xml_for_step1.xml")
    xdoc = readxml("xml_for_step1.xml")
    soup = root(xdoc)
    eles = elements(soup)
    first_sets = []
    fn = 1
    for ele in eles
        link = elements(ele)[1].content
        download_xml(link,"$dir/$fn.xml")
        fn+=1
        @show fn
    end
end

function step2_run(year_to_start,dir1,dir2)
    file_count = 0
    n_total = 0
    filelist = readdir("$dir1/")
    filelist_len = length(filelist)
    for index in 1:filelist_len
        continue_ = true
        while continue_
            xml_file = filelist[index]
            @show xml_file
            try
                file_count, n_total = download_html_roadmap_step2(xml_file,file_count,n_total,year_to_start,dir1,dir2)
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

#956477 -- n_total
function download_html_roadmap_step2(xml_file,file_count,n_total,year_to_start,dir1,dir2)
    function if_link_hansard(link)
        return occursin("hansardr80",link) || occursin("hansardr",link)
    end

    function compare_links(url1::String, url2::String)::Bool
        pattern = r"%2F\d+%22"    
        cleaned_url1 = replace(url1, pattern => "")
        cleaned_url2 = replace(url2, pattern => "")
        return cleaned_url1 == cleaned_url2
    end

    dates = []
    xdoc = readxml("$(dir1)/$xml_file")
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
                response = get_response(link)
                html_content = String(response.body)
                @show link
                doc = Gumbo.parsehtml(html_content)
                dsoup = doc.root
                date = find_date_subsoup(dsoup)
                if date != "N/A"
                    year = split(date,"-")[3]
                    if parse(Int,year) >= year_to_start

                        filename = "$(dir2)/$(date)_number$(n_total).html"
                        open(filename, "w") do file
                            write(file,html_content)
                        end
                        file_count += 1
                        @show file_count
                    end
                end
            end
        end
    end
    return file_count,n_total
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

function sitemap_get_xml_links_step3(xmlcsvfn,dir2)
    filelist = readdir("$(dir2)/")
    open(xmlcsvfn, "w") do io
        println(io,join(["date","xml_link","pdf_link"],"\t"))
        for file in filelist
            @show file
            text = read("$(dir2)/$file", String)
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



