module RunModule

export run_ParlinfoSpeechScraper

include("Utils.jl")
using .Utils

include("XMLModule.jl")
using .XMLModule

include("NodeModule.jl")
using .NodeModule

function get_time(fn)
    xdoc = readxml(fn)
    soup = root(xdoc)
    time_node = findfirst("//session.header/date",soup)
    time = time_node.content
    return time   
end

function which_toml(time)
    return "xpaths_set_up.toml"
end


function run_ParlinfoSpeechScraper(toml)
    for fn in readdir("xml_dir/", join=false)
        time = get_time(fn)
        toml_fn = which_toml(time)
        #run with toml_fn
    end 
end



end
