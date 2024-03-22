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

function download_xml(url,f)
    response = HTTP.get(url, ["User-Agent" => "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36"])
    open("$f", "w") do file
        write(file, String(response.body))
    end
end

function download_run()
    file_names,urls = read_csv("urls/201022.csv")
    destination = "urls/xml_files"
    Threads.@threads for n in 1:length(urls)
        @show n
        f = "urls/xml_files/$(file_names[n])"
        url = urls[n]
        download_xml(url,f)
    end
end

function download_single()
    url = "https://parlinfo.aph.gov.au/parlInfo/download/chamber/hansardr/27533/toc_unixml/House%20of%20Representatives_2023_12_07_Official.xml;fileType=text%2Fxml"
    f = "urls/test_files/2023-12-07.xml"
    download_xml(url,f)
end



function main()
    link = "https://parlinfo.aph.gov.au/parlInfo/search/display/display.w3p;query=Id%3A%22chamber%2Fhansards%2Fff07e01d-cd6d-4be6-bff6-f867d1054a78%2F0103%22;src1=sm1"
#
    #url = "https://www.example.com" # Make sure you use the full url with https and everything

    response = HTTP.request("GET", link)

    doc = Gumbo.parsehtml(String(response))
    subsoup = eachmatch(sel".twoBoxForm",doc.root)
    for ele in subsoup
       metapaddings = eachmatch(sel".metaPadding",ele)
       label = [eachmatch(sel".mdLabel",metapadding) for metapadding in metapaddings]
       value = [eachmatch(sel".mdValue",metapadding) for metapadding in metapaddings]
       #@show label[1][2][1].text
       @show label[1][2] value[1][2]
    end

end


