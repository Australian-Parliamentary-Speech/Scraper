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

In the directory nodes/Phases/, make a new directory"Phases/ExamplePhase/". Make a new directory "Phases/ExamplePhase/nodes/" to harbour new node definitions. Create a new phase julia file in the ExamplePhase directory PhaseExample.jl. A starting file might look at this:

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

## How to add a new flag
In order to add a new flag, or a new column of content, you would only need to interact with two functions: define\_flags and define\_headers. The dictionary that contains all information gets passed around and content gets added into it as the parsing goes on. The headers\_dict sets all headers to "N/A" to start with and they get overwritten during running. 


