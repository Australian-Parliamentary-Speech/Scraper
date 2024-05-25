using ParlinfoSpeechScraper
using EzXML
using InteractiveUtils
using Test

const RunModule = ParlinfoSpeechScraper.RunModule

@testset verbose = true "ParlinfoSpeechScraper.jl" begin

    @testset "speech_test" begin
        date = "2023-12-07"
        fn = "xmls/test_files/$date.xml"
        if false
            xdoc = readxml(fn)
            soup = root(xdoc) 
            debate_node = findfirst("//subdebate.1",soup)
        end
        RunModule.run_ParlinfoSpeechScraper(fn)
    end

end


