module Scraper
using AndExport

"""p_options: how would you like the process p"""
@xport mutable struct Run_Params
    general_option::Dict{String,Bool}
    which_sections:: Dict{String,Bool}
    question_option::Dict{String, Bool}
    talker_option ::Dict{String,Bool}
    section_xpaths::Dict{String,Vector{String}}
    xpaths::Dict{String,String}
end
end
