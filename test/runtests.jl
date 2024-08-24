using ParlinfoSpeechScraper
using EzXML
using InteractiveUtils
using Test

const RunModule = ParlinfoSpeechScraper.RunModule


@testset verbose = true "some problem" begin

    @test begin
        RunModule.run_xml("xmls/test.xml",dirname(@__FILE__),false,true)
        true

#        result = open("2023-12-07.csv", "r") do io
#            read(io)
#        end
    end
end


