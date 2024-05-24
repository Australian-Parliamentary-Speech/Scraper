using ParlinfoSpeechScraper
using EzXML
using InteractiveUtils
using Test

const RunModule = ParlinfoSpeechScraper.RunModule
const Node = RunModule.NodeModule.Node

@testset verbose = true "ParlinfoSpeechScraper.jl" begin

    @testset "speech_test" begin
        date = "2023-12-07"
        fn = "xmls/test_files/$date.xml"
        xdoc = readxml(fn)
        year = get_year(fn)
        soup = root(xdoc)
#        debate_node = findfirst("//chamber.xscript",soup)
        scrape_run = ParlinfoSpeechScraper.RunModule.Run_(year)
        ParlinfoSpeechScraper.RunModule.recurse(soup,scrape_run,soup,7)
    end

end


