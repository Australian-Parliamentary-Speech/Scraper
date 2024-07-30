using Documenter 
using Pkg
push!(LOAD_PATH,"../src/")
Pkg.develop(path = abspath(joinpath(@__DIR__, "../")))
using ParlinfoSpeechScraper

DocMeta.setdocmeta!(
    ParlinfoSpeechScraper,
    :DocTestSetup,
    :(using ParlinfoSpeechScraper);
    recursive = true,
    )

makedocs(
    sitename = "ParlinfoSpeechScraper Documentation",
    modules = [ParlinfoSpeechScraper],
    pages = [
    "API" => "api.md",
    "ParlinfoSpeechScraper" => "index.md",
    "Nodes" => "nodes.md",
    "Tutorials" => "tute.md"
    ]
    )

deploydocs(repo = "github.com/Australian-Parliamentary-Speech/Scraper.git")


