module ParlinfoSpeechScraper
using Reexport

# External packages
using BetterInputFiles
using ArgParse

# Internal packages
include("RunModule.jl")
@reexport using .RunModule

# Exports
export main

"""
get_args()

Parse command-line arguments

This function sets up and parses command-line arguments using the `ArgParse` package. It defines the arguments that can be passed to the script, including options for verbosity and input file path.
"""
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

"""
main()

Main function to process command-line arguments and run the program

This function serves as the entry point of the script. It processes command-line arguments, retrieves the necessary parameters, and calls the main processing function with those parameters.

Inputs:
None

Arguments:
- `args`: A dictionary containing the parsed command-line arguments.
    - `args["input"]`: Path to the input TOML file.
    - `args["verbose"]`: Boolean flag indicating if logging verbosity should be increased.
"""
function main()
    args = get_args()
    toml_path = args["input"]
    verbose = args["verbose"]
    main(toml_path,verbose)
end

"""
main(toml_path, verbose)

Main function to initialize and execute the Parlinfo Speech Scraper

This function initializes the input configuration from a TOML file specified by `toml_path` with optional verbosity controlled by `verbose`. It then runs the ParlinfoSpeechScraper using the configuration.

Inputs:
- `toml_path`: Path to the TOML configuration file.
- `verbose`: Boolean flag indicating if logging verbosity should be increased.
"""
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
