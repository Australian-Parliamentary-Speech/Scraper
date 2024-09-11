using CSV

function cover_percentage()
end

function year_to_dates(year)

end


function edit_csv(fn,::Type{<:AbstractPhase})
    csvfile = CSV.File(fn)
    headers_ = copy(propertynames(csvfile))
    header_to_num = edit_set_up(headers_)
    #any additional headers needed
    for header in [:Speaker,:Time]
        push!(headers_,header)
    end
    rows = eachrow(csvfile)
 
