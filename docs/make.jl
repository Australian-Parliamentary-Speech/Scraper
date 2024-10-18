using Documenter 
using Pkg
using CSV, DataFrames
using Latexify
using Dates

push!(LOAD_PATH,"../src/")
Pkg.develop(path = abspath(joinpath(@__DIR__, "../")))
using ParlinfoSpeechScraper

DocMeta.setdocmeta!(
    ParlinfoSpeechScraper,
    :DocTestSetup,
    :(using ParlinfoSpeechScraper);
    :(using CSV);
    recursive = true,
    )

makedocs(
    sitename = "ParlinfoSpeechScraper Documentation",
    modules = [ParlinfoSpeechScraper],
    pages = [
    "ParlinfoSpeechScraper" => "index.md",
    "XML download" => "download.md",
    "Usage" => "usage.md",
    "Advanced Usage" => "advusage.md",
    "Nodes" => "nodes.md",
    "Function references" => "functionreference.md",
    "Summaries" => "summaries.md"
    ]
    )

deploydocs(repo = "github.com/Australian-Parliamentary-Speech/Scraper.git")

#python3 -m http.server --bind localhost
