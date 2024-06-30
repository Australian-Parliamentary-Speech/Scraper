using HTTP
using Gumbo
using Cascadia
using Downloads
using CSV
using DataFrames
using EzXML

function create_dir(directory::AbstractString)
    if !isdir(directory)
        mkdir(directory)
        println("Directory created: $directory")
    end
end

function get_response(url)
    response = HTTP.get(url, ["User-Agent" => "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36"]) 
    return response
end

function download_xml(url,fname)
    response = get_response(url)
    open("$fname", "w") do file
        write(file, String(response.body))
    end
end

function read_csv(file_path::AbstractString)
    # Read the CSV file
    data = CSV.File(file_path) |> DataFrame
    # Extract the specified columns
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
    for one_result in eachmatch(sel"div.sumLink",result_soup)
        href = eachmatch(sel"a",one_result)[1].attributes["href"]
        xml_link = find_xml_link_from_page(href)
        date = match(r"\d{4}_\d{2}_\d{2}", xml_link)
        push!(xml_links,xml_link)
        if isnothing(date)
            date = match(r"\d{4}-\d{2}-\d{2}", xml_link)
            if isnothing(date)
                date = "N/A"
            else
                date = date.match
            end
        else
            date = date.match
        end
        @show date
        push!(dates,date)
    end

    for i in 1:length(dates)
        println(io, join([dates[i], xml_links[i], link], ","))
    end
    return soup
end

function next_page_link(soup)
    next_image = eachmatch(sel"img[title~=Next]",soup)[1]
    next_link = next_image.parent.attributes["href"]
    return next_link
end

function write_xml_one_page_new(link,io)
    function edit_link(date,id)
        date_ = split(date,"/")
        date_ = join([date_[end],date_[end-1],date_[end-2]],"_")
        link =  "https://parlinfo.aph.gov.au/parlInfo/download/chamber/hansardr/$(id)/toc_unixml/House%20of%20Representatives_$(date_).xml;fileType=text%2Fxml"
        return link
    end
    dates = []
    xml_links = []
    soup = get_soup(link)
    result_soup = eachmatch(sel"ul#results",soup)[1]
    for one_result in eachmatch(sel"div.sumMeta",result_soup)
        all_text = one_result.children[1].text
        date_text,collection,ID_text,source = split(all_text,"-")
        date = match(r"\d{2}/\d{2}/\d{4}", date_text).match
        ID = split(ID_text,"/")[end-1]
        xml_link = edit_link(date,ID)
        push!(xml_links,xml_link)
        @show date
        push!(dates,date)
    end

        for i in 1:length(dates)
            println(io, join([dates[i], xml_links[i]], ","))
        end
    return soup
end

#this is the function you run
function write_xml_links()
#    link="https://parlinfo.aph.gov.au/parlInfo/search/summary/summary.w3p;adv%3Dyes;orderBy%3D_fragment_number,doc_date-rev;query%3DDataset%3Ahansardr,hansardr80;resCount%3DDefault"
#    link = "https://parlinfo.aph.gov.au:443/parlInfo/search/summary/summary.w3p;adv=yes;orderBy=_fragment_number,doc_date-rev;page=500;query=Dataset%3Ahansardr,hansardr80;resCount=Default"
    link = "https://parlinfo.aph.gov.au/parlInfo/search/summary/summary.w3p;adv%3Dyes;orderBy%3D_fragment_number,doc_date-rev;query%3DDataset%3Ahansardr,hansardr80;resCount%3DDefault"
    maxnumber = 600
    number = 1
    open("xml_urls_second.csv", "w") do io
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

function download_xml_from_file(fn="xml_urls_second.csv")
    file_names,urls = read_csv(fn)
    open("download_debug.csv", "w") do io
        for n in 1:length(urls)
            url = urls[n]
            if occursin("_",file_names[n])
                year = split(file_names[n],"_")[1]
            elseif occursin("-",file_names[n])
                year = split(file_names[n],"-")[1]
            else
                year = "NA"
            end
            fname = "xmls/$year/$(file_names[n]).xml"
            create_dir("xmls/$year/")
            @show year
            try
                download_xml(url,fname)
            catch
                println(io,[url])
            end
        end
    end
end

function get_xml_files_from_pat_step1()
    xdoc = readxml("parlinfo_xml_1.xml")
    soup = root(xdoc)
    eles = elements(soup)
    first_sets = []
    fn = 1
    Threads.@threads for ele in eles
        link = elements(ele)[1].content
        download_xml(link,"pat_xmls_step1/$fn.xml")
        fn+=1
        @show fn
    end
end

function get_xml_links_from_pat_step2()
    date_regex = r"\d{4}-\d{2}-\d{2}"
    filelist = readdir("pat_xmls_step1/")
    open("all_xml_page_links.csv", "w") do io
        for xml_file in filelist
            dates = []
            @show xml_file
            xdoc = readxml("pat_xmls_step1/$xml_file")
            soup = root(xdoc)
            eles = elements(soup)
            for ele in eles
                link = elements(ele)[1].content
                date_match = match(date_regex, link)
                if !isnothing(date_match)
                    if !(date_match in dates)
                        push!(dates,date_match) 
                        println(io,join([date_match.match,link],","))
                    end
                end
            end
        end

    end
end

function process_all_xml_page_links(fn="all_xml_page_links.csv")
    open(fn) do f
        open("all_xml_page_links_edit.csv", "w") do io
            row = readline(f)
            previous_date = split(row,",")[1]
            println(io,row)
            while ! eof(f) 
                s = readline(f)   
                date = split(s,",")[1]
                if date != previous_date
                    previous_date = date
                    println(io, s)
                end
            end
        end
    end
end

function get_xml_links_from_pat_step3()
    row_no = 1
    open("all_xml_links.csv","w") do io
        open("all_xml_page_links_edit.csv") do f
            while ! eof(f) 
                s = readline(f) 
                date,href = split(s,",")
                xml_link = find_xml_link_from_page(href)
                @show date
                println(io,join([date,xml_link],","))
                sleep(30)
            end
            row_no += 1
            @show row_no
        end
    end
end


