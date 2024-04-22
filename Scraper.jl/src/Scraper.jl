module Scraper
using AndExport

"""p_options: how would you like the process p"""
@xport mutable struct Run_Params
    question_option::Dict{String, Bool}
    talker_option ::Dict{String,Bool}
    general_option::Dict{String,Bool}
    xpaths::Dict{String,String}
end
end
