using ParlinfoSpeechScraper
using EzXML
using InteractiveUtils
using Test

const RunModule = ParlinfoSpeechScraper.RunModule

@testset verbose = true "ParlinfoSpeechScraper.jl" begin

    @testset "2023" begin
        correct = open("2023-12-07-correct.csv", "r") do io
            read(io)
        end

        RunModule.run_xml("xmls/2023-12-07.xml",dirname(@__FILE__))

        result = open("2023-12-07.csv", "r") do io
            read(io)
        end

        @test result == correct
    end

end


