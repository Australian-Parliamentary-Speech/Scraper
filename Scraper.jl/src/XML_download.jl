using HTTP
using Gumbo
using AbstractTrees
using Cascadia
using DelimitedFiles
using Downloads
using CSV
using DataFrames

function create_dir(directory::AbstractString)
    if !isdir(directory)
        mkdir(directory)
        println("Directory created: $directory")
    else
        println("Directory already exists: $directory")
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

function download_all_xml_from_file(fn)
    file_names,urls = read_csv(fn)
    destination = "urls/xml_files_2024"
    Threads.@threads for n in 1:length(urls)
        fname = "urls/xml_files_2024/$(file_names[n]).xml"
        url = urls[n]
        year = split(file_names[n],"_")[1]
        if year == "2024"
            @show url
            download_xml(url,fname)
        end
    end
end

function month_to_no(month)
    print(month)
    if month == "Jan"
        return "01"
    elseif month == "Feb"
        return "02"
    elseif month == "Mar"
        return "03"
    elseif month == "May"
        return "05"
    elseif month == "Dec"
        return "12"
    else
        return month
    end
end

function date_process(date)
    list_ = split(date,"-")
    new_date = "$(list_[end])_$(month_to_no(list_[2]))_$(list_[1])"
    return new_date
end

function produce_xml_url(a)
    attributes = a.attributes
    date = attributes["aria-label"]
    date = date_process(date)
    link_ = attributes["href"]
    no = split(link_,"/")[end-1]
    link = "https://parlinfo.aph.gov.au/parlInfo/download/chamber/hansardr/$(no)/toc_unixml/House%20of%20Representatives_$(date).xml;fileType=text%2Fxml"
    return date,link
end

function write_xml_url(link)
    response = get_response(link)
    doc = Gumbo.parsehtml(String(response))
    soup = doc.root
    subsoups = eachmatch(sel"table",soup)
    xml_links = []
    dates = []
    for subsoup in subsoups
        as = eachmatch(sel"a",subsoup) 
        for a in as
            try
                date,link = produce_xml_url(a)
                push!(xml_links, link)
                push!(dates,date)
            catch
                nothing
            end
        end
    end
    open("urls/xml_urls.csv", "w") do io
        for i in 1:length(dates)
            println(io, join([dates[i], xml_links[i]], ","))
        end
    end
end



function test()
    if false
        link = "https://www.aph.gov.au/Parliamentary_Business/Hansard/Hansreps_2011"
    write_xml_url(link)
    else
        download_all_xml_from_file("urls/xml_urls.csv")
    end

end

function find_xml_url_from_page(link)
    response = get_response(link)
    doc = Gumbo.parsehtml(String(response))
    soup = doc.root
#    a = eachmatch(sel"img[title~='XML']",soup)[1].parent
#    @show a
#    link_ = a.attributes["href"]
    a = eachmatch(sel"a[title~='XML']",soup)[1]
    @show a
    date_node = eachmatch(sel"span.HPS-SODJobDate",soup)
    @show date_node
    date = eachmatch(sel"a",date_node[1])[1]
    @show date
    return link_
end


