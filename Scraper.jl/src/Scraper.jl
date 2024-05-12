module Scraper
using AndExport

@xport mutable struct Run_Params
    general_option::Dict{String,Any}
    which_sections:: Dict{String,Bool}
    question_option::Dict{String, Bool}
    talker_option ::Dict{String,Bool}
    section_xpaths::Dict{String,Any}
    xpaths::Dict{String,String}
end
end
