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


