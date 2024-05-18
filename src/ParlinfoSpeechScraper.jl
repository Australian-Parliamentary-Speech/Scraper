module ParlinfoSpeechScraper

# External packages
using BetterInputFiles
using ArgParse

# Internal packages
include("RunModule.jl")
using .RunModule

function get_args()
    s = ArgParseSettings()
    @add_arg_table! s begin
        "--verbose", "-v"
        action = :store_true
        "input"
        required = true
    end
    return parse_args(s)
end

function main()
    args = get_args()
    toml_path = args["input"]
    verbose = args["verbose"]
    main(toml_path,verbose)
end

function main(toml_path,verbose)
    toml = setup_input(toml_path,verbose)
    run_ParlinfoSpeechScraper(toml)
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end

end 
