# Advanced usage

## How to introduce a new node to the algorithm

Here is a template for adding a new node to the program in the default phase. If a node is needed for a particular phase, simply exchange the path from "nodes/" to "nodes/Phases/<yourphase>/nodes/". 

```julia
export ExampleNode

#defining a new abstract type for the node
abstract type ExampleNode{P} <: AbstractNode{P} end

#what are the xpaths associated with the node
function get_xpaths(::Type{<:ExampleNode})
    return ["xpath1","xpath2"]
end
```

The code above provides a starting point for adding a new node. The algorithm will now recognise the new nodes with xpath1 and xpath2 as nodenames. The default function process\_node is defined in NodeModule.jl. If a different process\_node function is preferred (same goes with any other already defined functions), a new process\_node can be defined in the present file in this way:

```julia
function process_node(node::Node{<:ExampleNode},node_tree)
    <insertyourcodehere>
end
```
## How to introduce a new phase into the algorithm

In the directory nodes/Phases/, make a new directory"Phases/ExamplePhase/". Make a new directory "Phases/ExamplePhase/nodes/" to harbour new node definitions. Create a new phase julia file in the ExamplePhase directory PhaseExample.jl. An example starting file  is given here:

```julia

abstract type PhaseExample <: AbstractPhase end

# Get Phase Node Overrides
phase_node_path = joinpath(@__DIR__, "nodes")

for path in readdir(phase_node_path, join=true)
    if isfile(path)
        include(path)
    end
end

# define which phase is this new phase defined over.
date_to_float converts a date year,month,day to float. For example, if the range of the phase goes from 1st Jan 1901 tp 6th Dec 1901:
upperbound = date_to_float(1901,12,6)
lowerbound = date_to_float(1901,1,1)
date_to_phase[(lowerbound,upperbound)] = PhaseExample
```

You can then add any new definition for node processing in the "Phases/ExamplePhase/nodes" directory.

### If the new phase is for senate
To define a new phase for senate is similar to adding a new phase in house. In the directory nodes/Phases/, make a new directory"Phases/ExamplePhase/". Make a new directory "Phases/ExamplePhase/nodes/" to harbour new node definitions. Create a new phase julia file in the ExamplePhase directory PhaseExample.jl. An example starting file for senate is given here:

```
abstract type PhaseExample <: AbstractPhase end

# Get Phase Node Overrides
phase_node_path = joinpath(@__DIR__, "nodes")

for path in readdir(phase_node_path, join=true)
    if isfile(path)
        include(path)
    end
end

# define which phase is this new phase defined over.
date_to_float converts a date year,month,day to float. For example, if the range of the phase goes from 1st Jan 1901 tp 6th Dec 1901:
upperbound = date_to_float(1901,12,6)
lowerbound = date_to_float(1901,1,1)
date_to_phase_senate[(lowerbound,upperbound)] = PhaseExample
```

If no phase for senate is defined, the phase detection defaults to phase detection for house.

## How to add a new flag
To add a new flag, or a new column of content, you would only need to interact with two functions: define\_flags and define\_headers. The dictionary that contains all information gets passed around and content gets added into it as the parsing goes on. The headers\_dict sets all headers to "N/A" to start with and they get overwritten during running. 

## How to add a new edit step

To add a new step in editting the CSVs, head to src/edit\_funcs and create your own file, for example, your\_edit\_process.jl. For the sake of clarity, it would be good to give the same name to the julia file and this function you create (as shown below). 

```julia
# if you created your own Phase, replace the ::Type{<:AbstractEditPhase} with your own Phase
function your_edit_process(input_fn,output_fn,::Type{<:AbstractEditPhase})
    csvfile = CSV.File(input_fn)
    #load all the headers such as speech_flag, content, speaker...
    headers_ = copy(propertynames(csvfile))
    # a dictionary to get which column to interact with. For example, if you want content, you do row[header_to_num[:content]] once you have rows
    header_to_num = edit_set_up(headers_)
    # a reverse dictionary of num_to_header in case it is useful
    num_to_header = reverse_dict(header_to_num)
    rows = eachrow(csvfile)
    open(output_fn,"w") do io
        write_row_to_io(io,string.(new_headers))
        for row in rows
            new_row = your_edit_fund(row)
            write_row_to_io(io,new_row)
        end
    end
end 
```

Once the file is written, append this name of the function into edit option, for example:
```
    edit = ["speaker_time","re","free_node","flatten","flatten","column_decorate","re", "your_edit_process"]
 
```
