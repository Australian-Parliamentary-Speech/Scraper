module ParlinfoSpeechScraper
using Reexport

# External packages
using BetterInputFiles
using ArgParse

# Internal packages
include("RunModule.jl")
@reexport using .RunModule

function get_args()
    s = ArgParseSettings()

    @add_arg_table! s begin
        "--verbose", "-v"
            action = :store_true
            help = "Increase logging verbosity"

        "input"
            help = "Path to input toml file. Can be relative or absolute."
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

# If running file as a script
# Automatically run main()
if abspath(PROGRAM_FILE) == @__FILE__
    main()
end

end 
