using ParlinfoSpeechScraper
using EzXML
using InteractiveUtils
using Test

const RunModule = ParlinfoSpeechScraper.RunModule

@testset verbose = true "ParlinfoSpeechScraper.jl" begin

    @testset "2023" begin
        RunModule.run_xml("xmls/2023-12-07.xml",dirname(@__FILE__))
    end

end


