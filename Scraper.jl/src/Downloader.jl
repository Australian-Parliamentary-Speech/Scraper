using HTTP
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
    urls = data[!, 2]    
    return urls[1:end]
end

function download_xml(url,destination)
    try
        response = HTTP.request("GET", url)
#        response = HTTP.get(url)
        if response.status == 200
            Downloads.download(url, destination)
            println("File downloaded successfully!") 
        else
            println("Error: HTTP status code ", response.status)
        end
    catch e
        println("Error: ",e)
    end
end

function download_run()
    urls = read_csv("urls/201022.csv")
    destination = "urls/xml_files/"
    for url in urls
        download_xml(url,destination)
    end
end


