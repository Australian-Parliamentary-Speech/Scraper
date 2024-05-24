using ParlinfoSpeechScraper
using EzXML
using InteractiveUtils
using Test

const RunModule = ParlinfoSpeechScraper.RunModule

@testset verbose = true "ParlinfoSpeechScraper.jl" begin

    @testset "speech_test" begin
        date = "2023-12-07"
        fn = "xmls/test_files/$date.xml"
#        debate_node = findfirst("//chamber.xscript",soup)
        RunModule.run_ParlinfoSpeechScraper(fn)
    end

end


