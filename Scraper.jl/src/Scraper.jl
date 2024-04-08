module Scraper
using AndExport

"""p_options: how would you like the process p"""
@xport mutable struct Run_Struct
    p_option::Dict{String, Bool}
    xpaths::Dict{String,String}
end
end
