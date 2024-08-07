using ParlinfoSpeechScraper
using EzXML
using InteractiveUtils
using Test

const RunModule = ParlinfoSpeechScraper.RunModule

@testset verbose = true "ParlinfoSpeechScraper.jl" begin

    @test skip=true "Phase2024" begin
        RunModule.run_xml("xmls/test.xml",dirname(@__FILE__))

        result = open("2023-12-07.csv", "r") do io
            read(io)
        end
    end


end


