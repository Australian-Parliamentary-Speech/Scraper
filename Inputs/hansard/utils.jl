using HTTP
using DataFrames
using Gumbo
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


function get_soup(link)
    response = get_response(link)
    doc = Gumbo.parsehtml(String(response))
    soup = doc.root
    return soup
end


function download_xml_from_file(fn,dir_xml,sept="/",delim_=" ")
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
                fname = "$dir_xml/$year/$(year)_$(month)_$(day).xml"
                create_dir("$dir_xml/$year/")
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
