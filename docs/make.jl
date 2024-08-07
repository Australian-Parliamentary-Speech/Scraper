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
    "ParlinfoSpeechScraper" => "index.md",
    "Usage" => "usage.md",
    "Advanced Usage" => "advusage.md",
    "Nodes" => "nodes.md",
    "Function references" => "functionreference.md",
    "Tests" => "test.md"
    ]
    )

deploydocs(repo = "github.com/Australian-Parliamentary-Speech/Scraper.git")

#python3 -m http.server --bind localhost
