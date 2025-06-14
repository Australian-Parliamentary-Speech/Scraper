module EditModule
using CSV,DataFrames
using ..NodeModule
using ..Utils
using ..XMLModule
export detect_edit_phase
export edit_main
export Editor
export re
export flatten
export AbstractEditPhase


abstract type AbstractEditPhase end

abstract type GenericEditPhase <: AbstractEditPhase end

struct Editor
    edit_funcs
    edit_phase::Type{<:AbstractEditPhase}
end

#Get Edit functions
const func_path = joinpath(@__DIR__,"edit_funcs")
for path in readdir(func_path,join=true)
    if isfile(path)
        include(path)
    end
end

# Included phases can add to this dictionary
date_to_phase = Dict()

# Included phases can add to this dictionary
range_to_phase = Dict()

# Get Phase Overwrites
#const phase_path = joinpath(func_path,"Phases")
#for dir in readdir(phase_path,join=true)
#    for path in readdir(dir,join=true)
#        if isfile(path)
#            include(path)
#        end
#    end
#end

function detect_edit_phase(date)
    # See if year has specific phase
    phase = get(date_to_phase, date, nothing)
    if ! isnothing(phase)
        return phase
    end

    # See if date in range with phase
    for (date_range,phase) in date_to_phase
        min_date, max_date = date_range
        if min_date <= date <= max_date
            return phase
        end
    end

    # Any other logic you want can go here

    # No specific phase for this date
    return AbstractEditPhase
end

"""
edit_set_up(headers)

Sets up a dictionary mapping each element in `headers` to its corresponding index.
"""
function edit_set_up(headers)
    return Dict(zip(headers,collect(1:length(headers)))) 
end

"""
func_list: a list of function names as string
editor: a struct with two parameters
"""
function edit_main(fn,editor::Editor)
    function which_csv(num,fn)
        if num > 0            
            fn = fn[1:end-4]
            return "$(fn)_edit_step$(num).csv"
        else
            return fn
        end
    end
    func_list = editor.edit_funcs
    if !isempty(func_list)
        edit_phase = editor.edit_phase
        funcs = [Symbol(f) for f in func_list]
        num = 0  
        for func in funcs
            resolved_func = getfield(EditModule, func)
            input_fn = which_csv(num,fn)
            num += 1
            output_fn = which_csv(num,fn)
            resolved_func(input_fn, output_fn,editor.edit_phase)
        end
    end
end

function cell_not_null(cell)
    return !(cell == "N/A" || cell == "FREE NODE" || cell == "None")
end



function is_stage_direction(row,header_to_num)
    row_ = @. collect(row)
    row = row_[1]
    flag_indices, all_flags = find_all_flags(row,header_to_num)
    if all(==(0), all_flags)
        return true
    end  
    return false 
end

function get_row(rows, row_no)
    row = rows[row_no]
    row_ = @. collect(row)
    return row_[1]
end


end
