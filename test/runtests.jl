using ParlinfoSpeechScraper
using EzXML
using InteractiveUtils
using Test

using ParlinfoSpeechScraper
const RunModule = ParlinfoSpeechScraper.RunModule
const Node = RunModule.NodeModule.Node

@testset verbose = true "ParlinfoSpeechScraper.jl" begin

    @testset "speech_test" begin
        date = "2023-12-07"
        xdoc = readxml("xmls/test_files/$date.xml")
        soup = root(xdoc)
        debate_node = findfirst("//speech",soup)
        scrape_run = ParlinfoSpeechScraper.RunModule.Run_(2023)
        ParlinfoSpeechScraper.RunModule.recurse(scrape_run,debate_node)
    end

end


